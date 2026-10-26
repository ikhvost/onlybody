#!/bin/bash
set -euo pipefail
site_root="$(cd "$(dirname "$0")/../.." && pwd)"
source_root="$site_root/onlybody/onlybody"
mkdir -p "$site_root/Website/dist/assets/muscles"
render_dir="$(mktemp -d /tmp/onlybody-site-muscles.XXXXXX)"
trap 'rm -rf "$render_dir"' EXIT
swiftc -module-cache-path "$render_dir/cache" -parse-as-library -o "$render_dir/export" \
  "$site_root/Website/Scripts/ExportMuscles.swift" \
  "$source_root/Shared/Theme/Theme.swift" \
  "$source_root/Shared/Navigation/TabSwipeThresholds.swift" \
  "$source_root/Domain/Catalog/MuscleGroup.swift" \
  "$source_root/Domain/Models/MuscleDiagram.swift" \
  "$source_root/Features/Library/MuscleAnatomyView.swift" \
  "$source_root/Features/Library/MuscleRegionPaths.swift" \
  "$source_root/Features/Library/AdditionalMuscleRegionPaths.swift"
"$render_dir/export" "$site_root"
