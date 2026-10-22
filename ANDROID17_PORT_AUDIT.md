# Android 17 / DerpFest port audit — Realme RMX3461 (ice)

Status: static source audit only. This is not a successful Android build and does not certify a bootable image.

## Confirmed from source

- DerpFest manifest branch `17` has a `snippets/derp.xml` manifest that maps `vendor/lineage` to the `android_vendor_derpfest` project.
- In that vendor tree, `config/common_mobile_full.mk` inherits `vendor/lineage/config/common_mobile.mk`; `config/telephony.mk` exists. The current `derp_ice.mk` inheritance paths therefore match the inspected DerpFest source layout.
- The device tree's `device.mk` inherits `device/oneplus/sm8350-common/common.mk` and `vendor/realme/ice/ice-vendor.mk`.
- The common device tree's `common.mk` also inherits `vendor/oneplus/sm8350-common/sm8350-common-vendor.mk`, and `BoardConfigCommon.mk` includes the matching vendor BoardConfig. The local manifest was missing this dependency; it has now been added as `Debarpan102/proprietary_vendor_oneplus_sm8350-common` on branch `seventeen`.
- The kernel repository contains `arch/arm64/configs/vendor/oplus_yupik_QGKI.config` with `CONFIG_ARCH_YUPIK=y`, and `arch/arm64/configs/vendor/lahaina-qgki_defconfig` with `CONFIG_ARCH_LAHAINA=y`. This confirms the files exist, not that the final kernel configuration or device pairing is correct.
- The proprietary vendor repository has an `ice-vendor.mk` on branch `seventeen`.
- The common tree has an OPlus/Qualcomm SM8350 configuration, and the device BoardConfig inherits its common BoardConfig.

## Findings requiring work before a real build

1. **YAAP overlay reference remains active.** `device.mk` adds `$(LOCAL_PATH)/overlay-yaap` to `DEVICE_PACKAGE_OVERLAYS`. The folder name alone does not prove its resources are YAAP-specific; inspect the resources and migrate/rename only after reviewing them. Do not delete it blindly.
2. **Device configuration is legacy-derived.** The existing device, common, kernel and proprietary vendor branches are named `seventeen`, but branch names alone do not prove Android 17 API, Soong, SELinux, VINTF, kernel, or vendor compatibility.
3. **Kernel target compatibility is unresolved.** The kernel defconfig and Yupik fragment both exist, but the device combines a common tree whose platform defaults include Lahaina with a Yupik-specific fragment. Verify this combination against the exact hardware and stock kernel/device configuration before building or flashing.
4. **VINTF and HAL compatibility are unverified.** Check device and ODM manifests, framework compatibility matrices, vendor HAL versions, init rc files, and SELinux policy against the DerpFest 17 base.
5. **Proprietary dependencies need a full file audit.** Confirm every referenced proprietary file exists, every copied destination is valid, and all required firmware/modules are available. A generated vendor makefile being present does not guarantee every source blob exists in the checkout.
6. **Product identity needs device-side validation.** `derp_ice.mk` currently sets the product/device/brand/model and GMS client ID, but it intentionally does not copy the Android 13 fingerprint override from the old YAAP product. Set release identity properties only from a verified stock build for this exact device.
7. **Duplicate copy entry.** `device.mk` lists `media/media_profiles_vendor.xml` twice at the same destination. Remove the duplicate only after checking no branch-specific changes are being lost; it is likely redundant but not itself proof of a build failure.

## Next safe engineering milestone

Run a source-level audit that resolves all `PRODUCT_COPY_FILES` source paths, validates referenced overlays/configs, parses VINTF XML, and checks that every inherited vendor makefile is supplied by the local manifest. Then run a full `lunch derp_ice-userdebug` product configuration and build on a runner with sufficient disk/RAM. Do not label this port build-ready until those checks and a complete compile pass.

## Safety

This target is Realme RMX3461 codename `ice`. It is not the OnePlus 15R. Do not flash images built from this tree to a different device.
