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

The tree uses the SM8350 common board configuration and appends `vendor/oplus_yupik_QGKI.config` to the kernel config. The common platform config and Yupik fragment must be treated together; do not replace the device fragment with a generic Lahaina config without checking the required NFC, touchscreen and Wi-Fi options. The device tree overrides the common tree's super/dynamic-partition size declarations; these values still need comparison with a verified stock RMX3461 partition map before any images are built for flashing.

## Important difference found against the LineageOS 23 reference

The reference tree's `BoardConfig.mk` defines the Soong namespace `OPLUS_LINEAGE_TOUCH_HAL` and points its include directory at `device/realme/ice/touch/include`. The current `lineage-24.0` branch initially lacked that `touch/include` directory. I ported the reference `TouchscreenGestureConfig.h` and added the matching Soong namespace/include configuration to `BoardConfig.mk`. The preflight now checks that the header exists and the include path is declared. This is a source-level port of the LineageOS gesture list, not yet proof that the full Android 17 touch HAL compiles or that every gesture works on hardware.

The current product intentionally does not inherit `overlay-yaap`. It must not be re-enabled just because the resources exist; first check the overlay resource names and values against the LineageOS 24 source and port only compatible resources. The six device-specific OPlus runtime overlay modules referenced in `device.mk` each have a matching local `Android.bp` declaration, and `init.oplus_ice.rc` is declared as a prebuilt module in `init/Android.bp`. The preflight workflow now checks these module declarations to catch accidental renames or missing module definitions.

## Remaining pre-build audit

1. Compile-test the newly ported touchscreen gesture header against the exact LineageOS 24 Touch HAL source and verify gesture behavior on device.
2. Audit `BoardConfig.mk`, kernel build variables, partition declarations, vendor makefiles, and the common tree against the selected LineageOS 24 source branch.
3. Review device and common VINTF manifests/matrices, init scripts, and SELinux policy for Android 17 compatibility. XML parsing alone does not prove framework/vendor interface compatibility.
4. Review OPlus resource packages listed in `device.mk`; ensure their module names exist in the synced `hardware/oplus` and that the selected branch provides the expected targets.
5. Validate proprietary blob source/destination mappings and firmware/vendor compatibility. Presence of a source path in Git is not proof that a blob works at runtime.
6. Complete a full source build, inspect the resulting images, and test boot/runtime behavior on the exact RMX3461 hardware before distributing anything.

## Safety and deliverable status

No full LineageOS Android 17 build or flashable ROM ZIP has been produced or verified. Do not flash the raw kernel `Image` as a ROM or boot image. Preserve the currently working YAAP installation until a complete, device-matched build and recovery path are available. Never flash images intended for RMX3461 to another device.


## Partition and VINTF audit findings (2026-10-23)

### Partition declarations

The current device BoardConfig.mk sets:

- BOARD_SUPER_PARTITION_SIZE := 10200547328 bytes (9.50 GiB, decimal 10.20 GB).
- BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE := 10196353024 bytes.
- The difference is exactly 4,194,304 bytes (4 MiB), matching the comment in the device tree.
- The inherited SM8350 common configuration declares boot and vendor_boot image limits of 201,326,592 bytes each and a DTBO limit of 25,165,824 bytes. These are build limits, not proof of the phone's physical partition sizes.
- The common dynamic partition group contains odm, product, system, system_ext, vendor, and vendor_dlkm.

The reference RMX3461 LineageOS 23 device tree has the same super/dynamic partition numbers. That establishes consistency with the reference source, not that the numbers match the user's installed stock/YAAP firmware. The official LineageOS SM8350 common tree has larger fallback defaults for super and dynamic partitions, but the device tree overrides them. Do not change these values based only on the common defaults; obtain a verified RMX3461 partition map or matching firmware metadata first.

### Common-tree delta to track

The selected local manifest pins nightx24/android_device_oneplus_sm8350-common at branch seventeen, not the official LineageOS common-tree branch. Comparing the custom common BoardConfigCommon.mk against LineageOS lineage-24.0 shows these differences relevant to future build/flash review:

- The official branch includes -include vendor/lineage/config/BoardConfigReservedSize.mk; the custom branch does not.
- The official branch adds --set_verification_disabled_flag to BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS; the custom branch does not.
- The common security patch date differs between these branches.

These differences are recorded for review only; do not blindly copy upstream AVB or partition settings. They can change image sizing, verified-boot behavior, and build policy, so reconcile them against the intended ROM source, firmware, and supported install method before producing images.

### VINTF findings

- The device tree contributes a framework compatibility matrix at vintf/compatibility_matrix.xml; it currently declares the face biometric AIDL HAL as optional.
- The device tree does not have its own vintf/manifest.xml. Device HAL declarations come from the selected SM8350 common tree, including vintf/manifest.xml and vintf/manifest_odm.xml.
- The custom common branch and official LineageOS common branch both provide those manifest files. Their presence and XML structure alone do not prove that Android 17's framework compatibility matrix accepts every declared vendor HAL or that each service exists in the target firmware.
- No full checkvintf run against a completed Android 17 source checkout and the actual target vendor/ODM images has been performed.

### Next gate

Before building a flashable package, compare the actual RMX3461 firmware's partition map and build fingerprint with these declarations; resolve the custom-common-tree deltas deliberately; then run the Android build's VINTF compatibility checks against the exact framework and vendor/ODM inputs. Until those checks and a complete source build pass, this branch remains a port-preparation tree, not a flashable ROM.


## Proprietary blob source audit (2026-10-23)

I compared the device tree's proprietary-files.txt against the recursive Git tree of nightx24/proprietary_vendor_realme_ice at branch seventeen, and checked the generated ice-vendor.mk source references against that same tree.

- proprietary-files.txt contains 944 non-comment entries.
- All 944 listed source paths were present in the vendor repository under proprietary/.
- ice-vendor.mk contains 617 proprietary source-copy references; all 617 referenced source paths were present in the vendor repository.
- The vendor repository tree contained 1,021 entries and the GitHub tree response was not truncated.
- The device blob list identifies its source firmware as Realme 9 5G SE RMX3461_13.1.0.100(EX01).

This is a repository path/existence check only. It does not validate blob hashes against the user's installed firmware, ELF dependencies, service registrations, SELinux permissions, VINTF compatibility, or runtime operation on Android 17. The source firmware version and actual target vendor/ODM build fingerprint must still be confirmed before flashing.


## Init and kernel-module integration audit (2026-10-23)

### Device-specific init configuration

- The device tree's init/Android.bp declares init.oplus_ice.rc as a device-specific prebuilt, and the source file exists.
- init.oplus_ice.rc configures the OPlus OTG switch and sets USB/Bluetooth display names when ro.boot.prjname=21695. The property value and sysfs path have not been validated against the user's current firmware/runtime.
- The device tree itself contains no top-level sepolicy directory or modules.load/modules.blocklist file in this branch's recursive Git tree. Policy and kernel-module loading therefore depend on inherited common/vendor/kernel configuration.

### Common-tree init and module configuration

- The custom SM8350 common tree contains 83 non-comment entries in modules.load and a blocklist for qca_cld3_wlan, with a comment that the target RC loads it after cold-boot calibration.
- init/init.target.rc invokes vendor_modprobe.sh, modprobe, audio DSP modules, WLAN modules, and several vendor services. The common proprietary vendor repository contains vendor_modprobe.sh, pd-mapper, pm-service, and pm-proxy.
- Several other init references (including lowirpcd, cnss_diag, fan_control, and modprobe) were not found as exact files in the checked common/device proprietary vendor trees. Some may be provided by the target firmware, Android source modules, symlinks, or alternate partitions; this path-only check cannot decide that. Treat them as dependencies requiring verification against the exact vendor/ODM images and final installed image contents, not as confirmed missing binaries.
- The init script requests cdsprm as a modprobe target, but cdsprm is not in modules.load. This may be loaded by a separate RC or provided under a different module naming scheme; verify the final module set and boot logs before changing load order.

### Compatibility limits and next gate

This audit is static source inspection only. It does not compile init scripts, resolve SELinux denials, prove kernel modules match the kernel ABI, or validate that services start on hardware. Next, run a full Android build and inspect the generated vendor/odm images and boot logs for unresolved init imports, missing executables/modules, failed service starts, and SELinux denials. Do not remove service declarations or alter module loading based only on these repository searches.
