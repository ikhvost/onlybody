#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
output=$(mktemp -d /tmp/onlybody-icon.XXXXXX)
trap 'rm -rf "$output"' EXIT
swiftc -parse-as-library \
    Scripts/AppIcon/RenderBrandAssets.swift \
    Apps/iOS/Sources/App/OBMarkView.swift \
    Apps/iOS/Sources/App/OWMarkView.swift \
    Apps/iOS/Sources/Shared/Theme/Theme.swift \
    -o "$output/render"
"$output/render" "${1:-OnlyBody}"
