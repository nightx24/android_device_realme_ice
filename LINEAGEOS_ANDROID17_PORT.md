# LineageOS Android 17 port — Realme RMX3461 (ice)

## Selected base

- ROM source: [LineageOS/android](https://github.com/LineageOS/android), branch `lineage-24.0`
- Manifest AOSP revision: `android-17.0.0_r1` (verified in the branch's `default.xml`)
- Device: Realme 9 SE / Realme Q3s, model `RMX3461`, codename `ice`
- Device tree branch: `lineage-24.0`
- Reference device tree: [pjgowtham/android_device_realme_ice](https://github.com/pjgowtham/android_device_realme_ice), branch `lineage-23.0`

## What has been prepared

- Created a separate `lineage-24.0` branch based on the existing device-tree work.
- Added `lineage_ice.mk` inheriting LineageOS's `vendor/lineage/config/common_full_phone.mk`.
- Updated `AndroidProducts.mk` to expose `lineage_ice-userdebug` and the other standard lunch choices.
- Added `build/local_manifests/lineage-ice.xml` to sync the device tree, vendor blobs, SM8350 common tree/vendor, OPlus hardware, and kernel.
- Removed the YAAP-specific resource overlay from the LineageOS product until its resources can be reviewed and ported.
- Corrected the vendor copy destination for the sound-trigger mixer configuration.
- Expanded GitHub Actions preflight checks to validate device-local files referenced by the product configuration.

## Important compatibility notes

The reference tree is on `lineage-23.0`, not `lineage-24.0`; it is a porting reference and has not been proven to compile on Android 17. The YAAP overlay is currently excluded rather than reused blindly. The common device tree, proprietary vendor trees, kernel, init scripts, future LineageOS overlays, VINTF declarations, and SELinux policy still need Android 17 compatibility checks.

The local manifest currently reuses the existing `seventeen` branches for the device's vendor/common/kernel repositories. Branch existence is checked by CI, but branch existence alone does not prove they are compatible with LineageOS 24.0.

The preflight workflow is static validation only. It does not sync the complete Android source, compile a ROM, create a flashable ZIP, or test hardware. A full Android source build normally requires several hundred GB of storage; a standard GitHub-hosted runner is generally insufficient.

## Build setup

On a build machine/runner with sufficient storage and RAM:

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0
mkdir -p .repo/local_manifests
curl -fL https://raw.githubusercontent.com/nightx24/android_device_realme_ice/lineage-24.0/build/local_manifests/lineage-ice.xml -o .repo/local_manifests/lineage-ice.xml
repo sync -c -j2
source build/envsetup.sh
lunch lineage_ice-userdebug
```

Do not begin the full compile until the product configuration and source compatibility review are complete.

## Flashing safety

Do not flash the raw kernel `Image` as if it were a boot image. Do not mix `boot.img`, `vendor_boot.img`, `dtbo.img`, or vendor firmware from different device builds. The current project has not produced a verified LineageOS Android 17 ROM ZIP or validated it on hardware. Keep a known-working RMX3461 ROM and matching firmware available before testing.
