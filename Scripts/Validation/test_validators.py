"""Regression tests for rejected architecture and catalog changes; no app stores are modified."""
import runpy
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
BOUNDARIES = runpy.run_path(str(HERE / 'check-boundaries.py'))
CATALOGS = runpy.run_path(str(HERE / 'check-catalogs.py'))
LOCALIZATIONS = runpy.run_path(str(HERE / 'check-localizations.py'))


class ValidatorTests(unittest.TestCase):
    def test_product_conditions_are_only_allowed_at_explicit_boundaries(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'Sources'
            for relative in ['App/AppConfiguration.swift', 'Shared/Preview/NativeDesignReviewFixture.swift']:
                path = root / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('#if DEBUG && (ONLYWEIGHTS || ONLYBODY)\n#endif\n')
            BOUNDARIES['validate'](root)
            feature = root / 'Features/Library.swift'
            feature.parent.mkdir()
            for condition in ['#if ONLYWEIGHTS', '#elseif DEBUG && !ONLYBODY', '#if (ONLYWEIGHTS || DEBUG)']:
                with self.subTest(condition=condition):
                    feature.write_text(condition + '\n#endif\n')
                    with self.assertRaisesRegex(ValueError, 'product compilation conditions'):
                        BOUNDARIES['validate'](root)
            feature.write_text('#if DEBUG // ONLYWEIGHTS is not a condition\n#endif\n// #if ONLYBODY\n')
            BOUNDARIES['validate'](root)

    def test_framework_boundaries_still_apply(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'Sources'
            path = root / 'Domain/Bad.swift'
            path.parent.mkdir(parents=True)
            for source in ['import SwiftData', 'import SwiftUI', 'let context: ModelContext']:
                with self.subTest(source=source):
                    path.write_text(source)
                    with self.assertRaises(ValueError):
                        BOUNDARIES['validate'](root)

    def test_keys_reject_removal_new_entries_and_duplicates(self):
        validate = CATALOGS['validate_catalog_keys']
        validate([{'name': 'Original'}], ['Original'], 'Fixture')
        for rows, registry, diagnostic in [
            ([{'name': 'Renamed'}], ['Original'], 'removed or renamed'),
            ([{'name': 'Original'}, {'name': 'New'}], ['Original'], 'unregistered'),
            ([{'name': 'Original'}, {'name': 'Original'}], ['Original'], 'duplicate'),
            ([{'name': 'Original'}], ['Original', 'Original'], 'duplicate'),
        ]:
            with self.subTest(diagnostic=diagnostic), self.assertRaisesRegex(ValueError, diagnostic):
                validate(rows, registry, 'Fixture')

    def test_product_localizations_reject_missing_foreign_and_unknown_resources(self):
        validate = LOCALIZATIONS['validate_exercise_lookup']
        rows = [{'name': 'Original'}]
        strings = {'exerciseOriginal': {}}
        validate(rows, {'Original': 'exerciseOriginal'}, strings, 'Fixture')
        for lookup in [{}, {'Original': 'missingSymbol'}, {'Original': 'exerciseOriginal', 'Foreign': 'exerciseOriginal'}]:
            with self.subTest(lookup=lookup), self.assertRaises(ValueError):
                validate(rows, lookup, strings, 'Fixture')
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            LOCALIZATIONS['read_lookup']('"Original": .one,\n"Original": .two,\n', 'Fixture')


if __name__ == '__main__':
    unittest.main()
