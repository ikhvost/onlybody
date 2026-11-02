#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ $# -gt 1 ]]; then
    echo 'Usage: Scripts/validate.sh [quick|full]'
    exit 1
fi
mode=${1:-full}
case "$mode" in
    quick|full) ;;
    *) echo 'Usage: Scripts/validate.sh [quick|full]'; exit 1 ;;
esac
expected=$(cat .xcode-version)
actual=$(xcodebuild -version | awk 'NR == 1 { print $2 }')
if [[ "$actual" != "$expected" && "${ALLOW_OLDER_XCODE:-0}" != "1" ]]; then
    echo "Expected Xcode $expected; selected $actual. Select it using DEVELOPER_DIR."
    echo "ALLOW_OLDER_XCODE=1 enables explicitly non-target compatibility checks."
    exit 1
fi
: "${DESTINATION:?Set DESTINATION to an installed iOS Simulator destination}"
output="${VALIDATION_OUTPUT:-$(mktemp -d /tmp/apps-validation-XXXXXX)}"
mkdir -p "$output"
echo "Validation mode: $mode (Functional test plan; Visual captures are opt-in)"
python3 Scripts/Validation/test_validators.py
python3 Scripts/Validation/check-boundaries.py
python3 Scripts/Validation/check-catalogs.py
python3 Scripts/Validation/check-localizations.py
swiftlint lint --strict --no-cache
for product in onlybody onlyweights; do
    selection=()
    if [[ "$mode" == quick ]]; then selection=("-only-testing:${product}Tests"); fi
    xcodebuild test -project Apps/iOS/Apps.xcodeproj -scheme "$product" \
        -testPlan Functional ${selection[@]+"${selection[@]}"} \
        -destination "$DESTINATION" -parallel-testing-enabled NO \
        -derivedDataPath "$output/DerivedData" -resultBundlePath "$output/$product-Tests.xcresult"
    if [[ "$mode" == full ]]; then
        xcodebuild build -project Apps/iOS/Apps.xcodeproj -scheme "$product" \
            -configuration Release -destination 'generic/platform=iOS Simulator' \
            -derivedDataPath "$output/DerivedData" CODE_SIGNING_ALLOWED=NO
    fi
done
if [[ "$mode" == quick ]]; then
    echo "Quick validation artifacts: $output"
    exit 0
fi
python3 Scripts/Validation/check-app-bundles.py "$output/DerivedData/Build/Products/Release-iphonesimulator"
if [[ "$actual" == "$expected" ]]; then
    swift run --package-path Scripts/StoreGenerator --scratch-path "$output/GeneratorBuild" \
        StoreGenerator "$output/onlybody-generated.store" Scripts/StoreGenerator/SeedData.json
    swift run --package-path Scripts/StoreGenerator --scratch-path "$output/GeneratorBuild" \
        StoreGenerator "$output/onlyweights-generated.store" Scripts/StoreGenerator/OnlyWeights/SeedData.json
else
    echo "Generator target-toolchain validation skipped: Swift 6.4 required."
fi
echo "Validation artifacts: $output"
