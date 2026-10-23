#!/usr/bin/env bash
# Build attempt for LineageOS Android 17 on Realme RMX3461 (ice).
# Run only in a NEW, empty Linux workspace with repo, git, curl and build tools installed.
# This script does not flash the phone and does not guarantee a successful build.

set -Eeuo pipefail

if [[ -e .repo ]]; then
  echo "ERROR: .repo already exists. Use a new, empty workspace; this script will not overwrite an existing checkout." >&2
  exit 2
fi

if [[ -n "$(find . -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
  echo "ERROR: Workspace is not empty. Start in a new empty directory." >&2
  exit 2
fi

JOBS="${BUILD_JOBS:-2}"
LOG="$PWD/build-ice-android17.log"
MANIFEST_URL="https://raw.githubusercontent.com/nightx24/android_device_realme_ice/lineage-24.0/build/local_manifests/lineage-ice.xml"

echo "== RMX3461 / ice / LineageOS Android 17 build attempt =="
echo "Workspace: $PWD"
echo "Build jobs: $JOBS"
df -h .
free -h || true

echo "== Initialize official LineageOS source =="
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0

echo "== Add the device local manifest =="
mkdir -p .repo/local_manifests
curl -fL --retry 3 "$MANIFEST_URL" -o .repo/local_manifests/lineage-ice.xml

echo "== Sync Android and device sources =="
repo sync -c -j"$JOBS" --fail-fast 2>&1 | tee "$LOG"

echo "== Configure product =="
set +u
source build/envsetup.sh
set -u
lunch lineage_ice-userdebug

echo "== Compile ROM (this can take many hours) =="
set -o pipefail
mka bacon -j"$JOBS" 2>&1 | tee -a "$LOG"

echo "== Build outputs =="
if [[ -d out/target/product/ice ]]; then
  find out/target/product/ice -maxdepth 1 -type f \\( -name '*.zip' -o -name '*.img' -o -name '*.sha256sum' \\) -printf '%f %s bytes\\n' | sort
else
  echo "Expected product output directory not found." >&2
  exit 3
fi

echo "Build command completed. Verify ZIP integrity, image/partition compatibility, VINTF, and device boot before flashing."
