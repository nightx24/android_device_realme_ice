# Realme RMX3461 (ice) — LineageOS Android 17 port notes

## Target and current status

- Device: Realme 9 5G SE, model RMX3461, codename `ice`.
- ROM source target: LineageOS `lineage-24.0` (Android 17 target).
- Device tree: `nightx24/android_device_realme_ice`, branch `lineage-24.0`.
- Product: `lineage_ice-userdebug`.
- Reference device tree: `pjgowtham/android_device_realme_ice`, branch `lineage-23.0`.

This branch is currently **port preparation only**. Static GitHub Actions checks have passed, but there is no completed full Android source build, no verified boot/recovery image, and no flashable ROM ZIP. See [ANDROID17_PORT_AUDIT.md](ANDROID17_PORT_AUDIT.md) for the current findings and blockers.

## Source setup (requires a suitably provisioned Linux build machine)

A full Android source sync and build commonly needs hundreds of GB of free storage, substantial RAM, and multiple CPU cores. A standard GitHub-hosted runner is generally not suitable for a full Android build. This repository's preflight workflow does not download or compile the full Android source tree.

From a clean workspace, initialize the LineageOS manifest and add this device's local manifest:

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0
mkdir -p .repo/local_manifests
curl -fL https://raw.githubusercontent.com/nightx24/android_device_realme_ice/lineage-24.0/build/local_manifests/lineage-ice.xml -o .repo/local_manifests/lineage-ice.xml
repo sync -c -j2
source build/envsetup.sh
lunch lineage_ice-userdebug
mka bacon
```

Treat this as a build attempt, not a promise that the current port compiles. The local manifest pins the device tree to `lineage-24.0` and the current custom SM8350 common device, kernel, OPlus hardware, and proprietary vendor repositories to their `seventeen` branches. Verify all manifest projects resolve and review the compatibility audit before starting a costly build. The `mka bacon` step may fail until source-level issues are resolved.

## Known checks and blockers

- The static preflight checks branch/file presence, product selection, manifest XML syntax, required local files, and selected Soong module declarations. It is not a compiler test.
- The device tree uses the SM8350/Lahaina common configuration and adds `vendor/oplus_yupik_QGKI.config`. Keep the device-specific Yupik, touchscreen, NFC, and Wi-Fi configuration together unless a verified source/build test justifies a change.
- The device tree sets `BOARD_SUPER_PARTITION_SIZE` to 10,200,547,328 bytes and `BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE` to 10,196,353,024 bytes (a 4 MiB difference). These match the reference device tree but have **not** been verified against the physical partition map of the user's installed firmware.
- The selected custom common tree differs from official LineageOS `lineage-24.0` in reserved-size configuration, AVB flags, and security patch declaration. See the port audit; do not blindly copy settings or assume these differences are harmless.
- VINTF XML exists, but `checkvintf` has not been run against a completed Android 17 build and the exact target vendor/ODM images.
- Proprietary blob mappings, camera/audio/display behavior, init services, SELinux, and hardware runtime behavior still need full-build and device validation.

## Firmware and flashing safety

Do not flash anything from this branch yet. Preserve the currently working ROM and recovery path. A raw kernel `Image` is not a `boot.img`, recovery image, OTA, or ROM ZIP. Before any flashable package is assembled, verify the exact RMX3461 firmware build, physical partition sizes, matching boot/vendor_boot/dtbo components, AVB requirements, and installation/recovery procedure. Do not use images from another model or infer physical partition sizes from BoardConfig alone.
