#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
expected=$(cat .xcode-version)
actual=$(xcodebuild -version | awk 'NR == 1 { print $2 }')
if [[ "$actual" != "$expected" && "${ALLOW_OLDER_XCODE:-0}" != "1" ]]; then
    echo "Expected Xcode $expected; selected $actual. Select it using DEVELOPER_DIR."
    echo "ALLOW_OLDER_XCODE=1 enables explicitly non-target compatibility checks."
    exit 1
fi
: "${DESTINATION:?Set DESTINATION to an installed iOS Simulator destination}"
output="${VALIDATION_OUTPUT:-/tmp/onlybody-validation-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$output"
python3 Scripts/Validation/check-boundaries.py
python3 Scripts/ExerciseMedia/generate.py --check
python3 Scripts/StoreGenerator/generate-difficulties.py --check
swiftlint lint --strict --no-cache
xcodebuild test -project onlybody/onlybody.xcodeproj -scheme onlybody \
    -destination "$DESTINATION" -parallel-testing-enabled NO \
    -derivedDataPath "$output/DerivedData" -resultBundlePath "$output/Tests.xcresult"
xcodebuild build -project onlybody/onlybody.xcodeproj -scheme onlybody \
    -configuration Release -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$output/DerivedData" CODE_SIGNING_ALLOWED=NO
if [[ "$actual" == "$expected" ]]; then
    swift run --package-path Scripts/StoreGenerator --scratch-path "$output/GeneratorBuild" \
        StoreGenerator "$output/generated.store" Scripts/StoreGenerator/SeedData.json
else
    echo "Generator target-toolchain validation skipped: Swift 6.4 required."
fi
echo "Validation artifacts: $output"
