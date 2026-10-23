# LineageOS Android 17 port audit — Realme RMX3461 (ice)

Status: source/static audit only. The GitHub Actions preflight passed, but this is **not** an Android source build and does not certify a bootable image or flashable ZIP.

## Current target

- Device: Realme RMX3461, codename `ice`
- ROM source branch: LineageOS `lineage-24.0` (Android 17 target)
- Device tree branch: [nightx24/android_device_realme_ice:lineage-24.0](https://github.com/nightx24/android_device_realme_ice/tree/lineage-24.0)
- Reference device tree: [pjgowtham/android_device_realme_ice:lineage-23.0](https://github.com/pjgowtham/android_device_realme_ice/tree/lineage-23.0)
- Local manifest: `build/local_manifests/lineage-ice.xml`

## Checks completed

The [LineageOS 24.0 Android 17 preflight workflow](https://github.com/nightx24/android_device_realme_ice/actions/runs/39897772976) completed successfully on 2026-10-23. Its checks verified that expected remote branches exist, the product selection and local manifest are present, referenced device-local files exist, and device XML resources parse. It does not sync/build the complete Android source tree.

The current `device.mk` inherits `device/oneplus/sm8350-common/common.mk` and `vendor/realme/ice/ice-vendor.mk`. The product file `lineage_ice.mk` inherits the device configuration and LineageOS `common_full_phone.mk`, and identifies the product as `lineage_ice` / device `ice` / model `RMX3461`.

The tree uses the SM8350 common board configuration and appends `vendor/oplus_yupik_QGKI.config` to the kernel config. The common platform config and Yupik fragment must be treated together; do not replace the device fragment with a generic Lahaina config without checking the required NFC, touchscreen and Wi-Fi options.

## Important difference found against the LineageOS 23 reference

The reference tree's `BoardConfig.mk` defines the Soong namespace `OPLUS_LINEAGE_TOUCH_HAL` and points its include directory at `device/realme/ice/touch/include`. The current `lineage-24.0` branch initially lacked that `touch/include` directory. I ported the reference `TouchscreenGestureConfig.h` and added the matching Soong namespace/include configuration to `BoardConfig.mk`. The preflight now checks that the header exists and the include path is declared. This is a source-level port of the LineageOS gesture list, not yet proof that the full Android 17 touch HAL compiles or that every gesture works on hardware.

The current product intentionally does not inherit `overlay-yaap`. It must not be re-enabled just because the resources exist; first check the overlay resource names and values against the LineageOS 24 source and port only compatible resources.

## Remaining pre-build audit

1. Compile-test the newly ported touchscreen gesture header against the exact LineageOS 24 Touch HAL source and verify gesture behavior on device.
2. Audit `BoardConfig.mk`, kernel build variables, partition declarations, vendor makefiles, and the common tree against the selected LineageOS 24 source branch.
3. Review device and common VINTF manifests/matrices, init scripts, and SELinux policy for Android 17 compatibility.
4. Review OPlus resource packages listed in `device.mk`; ensure their module names exist in the synced `hardware/oplus` and that the selected branch provides the expected targets.
5. Validate proprietary blob source/destination mappings and firmware/vendor compatibility. Presence of a source path in Git is not proof that a blob works at runtime.
6. Complete a full source build, inspect the resulting images, and test boot/runtime behavior on the exact RMX3461 hardware before distributing anything.

## Safety and deliverable status

No full LineageOS Android 17 build or flashable ROM ZIP has been produced or verified. Do not flash the raw kernel `Image` as a ROM or boot image. Preserve the currently working YAAP installation until a complete, device-matched build and recovery path are available. Never flash images intended for RMX3461 to another device.
