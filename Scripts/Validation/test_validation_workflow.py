"""Verify validation scope and cache reuse without building or launching either app."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class ValidationWorkflowTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix='validation-workflow-')
        self.addCleanup(directory.cleanup)
        self.scratch = Path(directory.name)
        self.run_count = 0
        shim = self.scratch / 'tool'
        shim.write_text('''#!/bin/sh
name=${0##*/}
printf '%s\\0' "$name" "$@" >> "$WORKFLOW_COMMAND_LOG"
printf '\\n' >> "$WORKFLOW_COMMAND_LOG"
if [ "$name" = xcodebuild ] && [ "$1" = -version ]; then
    printf 'Xcode %s\\n' "$WORKFLOW_XCODE_VERSION"
fi
if [ "$name" = xcodebuild ] && [ "$1" = test ] && [ "$WORKFLOW_FAIL_TEST" = 1 ]; then
    exit 42
fi
exit 0
''')
        shim.chmod(0o755)
        for name in ['xcodebuild', 'swiftlint', 'swift', 'python3']:
            (self.scratch / name).symlink_to(shim)

    def run_validation(self, *arguments, cache=None, fail_test=False):
        self.run_count += 1
        log = self.scratch / f'commands-{self.run_count}.log'
        environment = dict(os.environ)
        environment.pop('VALIDATION_DERIVED_DATA', None)
        environment.update(
            PATH=f'{self.scratch}:/usr/bin:/bin:/usr/sbin:/sbin',
            DESTINATION='platform=iOS Simulator,name=Fixture',
            VALIDATION_OUTPUT=str(self.scratch / f'results-{self.run_count}'),
            ALLOW_OLDER_XCODE='0', WORKFLOW_COMMAND_LOG=str(log),
            WORKFLOW_XCODE_VERSION=(ROOT / '.xcode-version').read_text().strip(),
            WORKFLOW_FAIL_TEST='1' if fail_test else '0',
        )
        if cache is not None:
            environment['VALIDATION_DERIVED_DATA'] = str(cache)
        result = subprocess.run(
            ['bash', str(ROOT / 'Scripts/validate.sh'), *arguments],
            env=environment, capture_output=True, text=True, timeout=15,
        )
        calls = [line.split('\0')[:-1] for line in log.read_text().splitlines()] if log.exists() else []
        return result, calls

    def test_quick_and_default_run_only_unit_and_integration_tests_for_both_products(self):
        for arguments in [('quick',), ()]:
            with self.subTest(arguments=arguments):
                result, calls = self.run_validation(*arguments)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                tests = [call for call in calls if call[:2] == ['xcodebuild', 'test']]
                self.assertEqual(len(tests), 2)
                for product, call in zip(['onlybody', 'onlyweights'], tests):
                    self.assertEqual(call[call.index('-scheme') + 1], product)
                    self.assertIn(f'-only-testing:{product}Tests', call)
                    self.assertIn('Functional', call)
                self.assertFalse(any(call[:2] == ['xcodebuild', 'build'] or call[0] == 'swift' for call in calls))

    def test_full_runs_shared_checks_once_and_includes_ui_release_bundles_and_seed_generation(self):
        result, calls = self.run_validation('full')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for script in ['test_validators.py', 'test_validation_workflow.py', 'check-boundaries.py',
                       'check-catalogs.py', 'check-localizations.py', 'check-app-bundles.py']:
            self.assertEqual(sum(call[:2] == ['python3', f'Scripts/Validation/{script}'] for call in calls), 1)
        self.assertEqual(sum(call[0] == 'swiftlint' for call in calls), 1)
        tests = [call for call in calls if call[:2] == ['xcodebuild', 'test']]
        builds = [call for call in calls if call[:2] == ['xcodebuild', 'build']]
        self.assertEqual(len(tests), 2)
        self.assertEqual(len(builds), 2)
        self.assertTrue(all('Functional' in call and not any(arg.startswith('-only-testing:') for arg in call) for call in tests))
        self.assertTrue(all('Release' in call for call in builds))
        self.assertEqual(sum(call[0] == 'swift' for call in calls), 2)

    def test_modes_reuse_default_cache_but_keep_result_bundles_separate(self):
        runs = []
        for mode in ['quick', 'full']:
            result, calls = self.run_validation(mode)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            caches = {call[call.index('-derivedDataPath') + 1] for call in calls if '-derivedDataPath' in call}
            self.assertEqual(caches, {str(ROOT / 'DerivedData/Validation')})
            runs.append({call[call.index('-resultBundlePath') + 1] for call in calls if '-resultBundlePath' in call})
        self.assertTrue(runs[0].isdisjoint(runs[1]))

    def test_custom_cache_is_used_for_builds_bundle_checks_and_generator(self):
        cache = self.scratch / 'custom cache'
        result, calls = self.run_validation('full', cache=cache)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for call in calls:
            if '-derivedDataPath' in call:
                self.assertEqual(call[call.index('-derivedDataPath') + 1], str(cache))
            if call[0] == 'swift':
                self.assertEqual(call[call.index('--scratch-path') + 1], str(cache / 'StoreGenerator'))
        bundle_check = next(call for call in calls if call[:2] == ['python3', 'Scripts/Validation/check-app-bundles.py'])
        self.assertEqual(bundle_check[2], str(cache / 'Build/Products/Release-iphonesimulator'))

    def test_removed_ui_mode_and_invalid_arguments_are_rejected_before_running_tools(self):
        for arguments in [('ui',), ('invalid',), ('quick', 'full')]:
            with self.subTest(arguments=arguments):
                result, calls = self.run_validation(*arguments)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(calls, [])

    def test_failed_tests_stop_full_before_release_builds_and_seed_generation(self):
        result, calls = self.run_validation('full', fail_test=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(sum(call[:2] == ['xcodebuild', 'test'] for call in calls), 1)
        self.assertFalse(any(call[:2] == ['xcodebuild', 'build'] or call[0] == 'swift' for call in calls))


if __name__ == '__main__':
    unittest.main()
