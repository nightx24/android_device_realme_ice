# Android 17 / DerpFest port audit — Realme RMX3461 (ice)

Status: static source audit only. This is not a successful Android build and does not certify a bootable image.

## Lahaina target and remaining kernel-fragment question

The project owner has confirmed that **Lahaina is the intended platform**. Treat the inherited common tree's `TARGET_BOARD_PLATFORM := lahaina` and `vendor/lahaina-qgki_defconfig` as the intended base; do not switch the port to Yupik based only on the fragment name.

One item still needs verification before a full build: device `BoardConfig.mk` appends `vendor/oplus_yupik_QGKI.config`, and that fragment sets `CONFIG_ARCH_YUPIK=y`. The kernel base defconfig sets `CONFIG_ARCH_LAHAINA=y`. The Yupik fragment also contains device-specific NFC, touchpanel, and Wi-Fi options, so removing it wholesale could break hardware features. Review the exact kernel configuration merge behavior and source-device lineage; then retain, replace, or split the fragment so the final configuration matches Lahaina while preserving the required device drivers.

This is a **kernel config consistency check**, not evidence that the Lahaina common tree itself is wrong. Confirm the final merged `.config` and verify that the device tree, vendor blobs, and kernel sources all match the intended hardware before building or flashing.

## Confirmed from source

- DerpFest manifest branch `17` has a `snippets/derp.xml` manifest that maps `vendor/lineage` to the `android_vendor_derpfest` project.
- In that vendor tree, `config/common_mobile_full.mk` inherits `vendor/lineage/config/common_mobile.mk`; `config/telephony.mk` exists. The current `derp_ice.mk` inheritance paths therefore match the inspected DerpFest source layout.
- The device tree's `device.mk` inherits `device/oneplus/sm8350-common/common.mk` and `vendor/realme/ice/ice-vendor.mk`.
- The common device tree's `common.mk` also inherits `vendor/oneplus/sm8350-common/sm8350-common-vendor.mk`, and `BoardConfigCommon.mk` includes the matching vendor BoardConfig. The local manifest includes `Debarpan102/proprietary_vendor_oneplus_sm8350-common` on branch `seventeen`.
- The kernel repository contains `arch/arm64/configs/vendor/oplus_yupik_QGKI.config` with `CONFIG_ARCH_YUPIK=y`, and `arch/arm64/configs/vendor/lahaina-qgki_defconfig` with `CONFIG_ARCH_LAHAINA=y`.
- The proprietary vendor repository has an `ice-vendor.mk` on branch `seventeen`.

## Other findings requiring work before a real build

1. **YAAP overlay reference remains active.** `device.mk` adds `$(LOCAL_PATH)/overlay-yaap` to `DEVICE_PACKAGE_OVERLAYS`. The folder name alone does not prove its resources are YAAP-specific; inspect the resources and migrate/rename only after reviewing them. Do not delete it blindly.
2. **Android 17 compatibility is unproven.** Branch names do not prove Soong, SELinux, VINTF, HAL, kernel, or vendor compatibility.
3. **VINTF and HAL compatibility are not fully verified.** Check device and ODM manifests, framework compatibility matrices, vendor HAL versions, init rc files, and SELinux policy against the DerpFest 17 base.
4. **Proprietary dependencies need a full file audit.** Confirm every referenced proprietary file exists, every copied destination is valid, and all required firmware/modules are available.
5. **Product identity needs device-side validation.** `derp_ice.mk` sets product/device/brand/model and GMS client ID, but the model and release identity must be checked against a verified stock build for this exact device.
6. **Duplicate copy entry.** `device.mk` lists `media/media_profiles_vendor.xml` twice at the same destination. Review and remove only if confirmed redundant.

## Next safe engineering milestone

First resolve the chipset/common-tree/kernel mismatch using verified stock device information and a genuinely matching common tree. Only then audit every `PRODUCT_COPY_FILES` source, overlays, VINTF, proprietary blobs and SELinux, run `lunch derp_ice-userdebug`, and attempt a full build on a runner with sufficient disk/RAM. Do not label this port build-ready until a complete compile and hardware validation pass.

## Safety

This tree declares Realme RMX3461 codename `ice`. It is not the OnePlus 15R. Do not flash images built from this tree to a different device.
