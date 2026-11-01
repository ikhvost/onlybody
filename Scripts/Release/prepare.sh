#!/bin/bash
# Validate both products, then archive one product for device distribution.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: Scripts/Release/prepare.sh <onlybody|onlyweights> <version> <build>

Example:
  DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' \
    Scripts/Release/prepare.sh onlybody 1.2.0 42

Required environment:
  DESTINATION       Installed iOS Simulator destination for full validation.
Optional environment:
  DEVELOPER_DIR     Xcode matching .xcode-version.
  RELEASE_OUTPUT    New output directory (must not already exist).
                    Default: Release/<product>-<version>-<build>-<unique suffix>
  ALLOW_PROVISIONING_UPDATES=1
                    Allow Xcode to manage signing profiles using its account.

Runs full validation for both apps and creates one signed Release .xcarchive.
Does not export an IPA, upload, submit for review, or modify source versions.
EOF
}

fail() {
    echo "Error: $*" >&2
    exit 1
}

if [[ $# == 1 && ( "$1" == '--help' || "$1" == '-h' ) ]]; then
    usage
    exit 0
fi
if [[ $# != 3 ]]; then
    usage >&2
    exit 1
fi

product=$1
version=$2
build=$3
case "$product" in
    onlybody|onlyweights) ;;
    *) fail 'Product must be onlybody or onlyweights.' ;;
esac
[[ "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] ||
    fail 'Version must contain three numeric components, for example 1.2.0.'
[[ "$build" =~ ^[1-9][0-9]{0,3}$ ]] ||
    fail 'Build must be a positive integer from 1 to 9999.'
[[ -n "${DESTINATION:-}" ]] || fail 'Set DESTINATION to an installed iOS Simulator destination.'
case "${ALLOW_PROVISIONING_UPDATES:-0}" in
    0|1) ;;
    *) fail 'ALLOW_PROVISIONING_UPDATES must be 0 or 1.' ;;
esac

# Resolve a caller-supplied relative output path before changing directories.
if [[ -n "${RELEASE_OUTPUT:-}" && "$RELEASE_OUTPUT" != /* ]]; then
    RELEASE_OUTPUT="$PWD/$RELEASE_OUTPUT"
fi
cd "$(dirname "$0")/../.."
root=$PWD
for tool in xcodebuild python3 swift swiftlint codesign; do
    command -v "$tool" >/dev/null || fail "Required tool not found: $tool"
done
expected=$(cat .xcode-version)
actual=$(xcodebuild -version | awk 'NR == 1 { print $2 }')
[[ "$actual" == "$expected" ]] ||
    fail "Expected Xcode $expected; selected $actual. Set DEVELOPER_DIR. Release preparation does not allow older Xcode."

if [[ -n "${RELEASE_OUTPUT:-}" ]]; then
    mkdir -p "$(dirname "$RELEASE_OUTPUT")"
    mkdir "$RELEASE_OUTPUT" || fail 'RELEASE_OUTPUT must be a new directory; existing artifacts are never overwritten.'
    output=$(cd "$RELEASE_OUTPUT" && pwd)
else
    mkdir -p "$root/Release"
    output=$(mktemp -d "$root/Release/$product-$version-$build-XXXXXX")
fi
trap 'echo "Release preparation failed. Retained artifacts: $output" >&2' ERR
archive="$output/$product.xcarchive"
echo "Release artifacts: $output"
{
    echo "Product: $product"
    echo "Version: $version"
    echo "Build: $build"
    echo "Xcode: $actual"
    echo "Commit: $(git rev-parse HEAD)"
    echo "Created (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo 'Working tree status at start:'
    git status --short
} > "$output/build-info.txt"

ALLOW_OLDER_XCODE=0 VALIDATION_OUTPUT="$output/Validation" \
    bash Scripts/validate.sh 2>&1 | tee "$output/validation.log"

signing_options=()
if [[ "${ALLOW_PROVISIONING_UPDATES:-0}" == 1 ]]; then
    signing_options+=(-allowProvisioningUpdates)
fi
xcodebuild archive \
    -project onlybody/onlybody.xcodeproj -scheme "$product" \
    -configuration Release -destination 'generic/platform=iOS' \
    -archivePath "$archive" -derivedDataPath "$output/DerivedData" \
    -resultBundlePath "$output/Archive.xcresult" \
    ${signing_options[@]+"${signing_options[@]}"} \
    "MARKETING_VERSION=$version" "CURRENT_PROJECT_VERSION=$build" \
    CODE_SIGNING_ALLOWED=YES CODE_SIGNING_REQUIRED=YES \
    2>&1 | tee "$output/archive.log"

app="$archive/Products/Applications/$product.app"
python3 - "$app" "$product" "$version" "$build" <<'PY'
import plistlib
import sys
from pathlib import Path

app, product, version, build = sys.argv[1:]
bundle = Path(app)
with (bundle / 'Info.plist').open('rb') as source:
    info = plistlib.load(source)
expected = {
    'CFBundleIdentifier': f'ikhvost.{product}',
    'CFBundleShortVersionString': version,
    'CFBundleVersion': build,
    'CFBundleSupportedPlatforms': ['iPhoneOS'],
}
for key, value in expected.items():
    if info.get(key) != value:
        raise SystemExit(f'Archive mismatch for {key}: {info.get(key)!r}; expected {value!r}')
if not (bundle / 'embedded.mobileprovision').is_file():
    raise SystemExit('Archive has no embedded provisioning profile')
if list(bundle.rglob('*.store-wal')) or list(bundle.rglob('*.store-shm')):
    raise SystemExit('Archive contains SQLite sidecars')
PY
codesign --verify --deep --strict "$app" 2>&1 | tee "$output/signature.log"
touch "$output/PREPARED"
echo "Prepared archive: $archive"
echo "Open in Xcode Organizer: open '$archive'"
echo 'Before distribution, complete the manual release review in Scripts/ExerciseMedia/CHECKLIST.md.'
