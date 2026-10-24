#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
output=$(mktemp -d /tmp/onlybody-icon.XXXXXX)
trap 'rm -rf "$output"' EXIT
swiftc -parse-as-library \
    Scripts/AppIcon/RenderBrandAssets.swift \
    onlybody/onlybody/App/OBMarkView.swift \
    onlybody/onlybody/App/OWMarkView.swift \
    onlybody/onlybody/Shared/Theme/Theme.swift \
    onlybody/onlybody/Shared/Navigation/TabSwipeThresholds.swift \
    -o "$output/render"
"$output/render" "${1:-OnlyBody}"
