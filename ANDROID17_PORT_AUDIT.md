# Android 17 / DerpFest port audit — Realme RMX3461 (ice)

Status: static source audit only. This is not a successful Android build and does not certify a bootable image.

## Lahaina target and remaining kernel-fragment question

The project owner has confirmed that **Lahaina is the intended platform**. Treat the inherited common tree's `TARGET_BOARD_PLATFORM := lahaina` and `vendor/lahaina-qgki_defconfig` as the intended base; do not switch the port to Yupik based only on the fragment name.

One item still needs verification before a full build: device `BoardConfig.mk` appends `vendor/oplus_yupik_QGKI.config`, and that fragment sets `CONFIG_ARCH_YUPIK=y`. The kernel base defconfig sets `CONFIG_ARCH_LAHAINA=y`. The Yupik fragment also contains device-specific NFC, touchpanel, and Wi-Fi options, so removing it wholesale could break hardware features. Review the exact kernel configuration merge behavior and source-device lineage; then retain, replace, or split the fragment so the final configuration matches Lahaina while preserving the required device drivers.

This is a **kernel config consistency check**, not evidence that the Lahaina common tree itself is wrong. Confirm the final merged `.config` and verify that the device tree, vendor blobs, and kernel sources all match the intended hardware before building or flashing.

## Confirmed from source

- **Local manifest branch mismatch fixed:** the device project now syncs `refs/heads/ice-17`, matching the active port branch. Previously it requested `refs/heads/seventeen`, which could silently sync a different revision despite building from the `ice-17` branch in the preflight checkout. The workflow now checks the active branch and validates this manifest revision.

- DerpFest manifest branch `17` has a `snippets/derp.xml` manifest that maps `vendor/lineage` to the `android_vendor_derpfest` project.
- In that vendor tree, `config/common_mobile_full.mk` inherits `vendor/lineage/config/common_mobile.mk`; `config/telephony.mk` exists. The current `derp_ice.mk` inheritance paths therefore match the inspected DerpFest source layout.
- The device tree's `device.mk` inherits `device/oneplus/sm8350-common/common.mk` and `vendor/realme/ice/ice-vendor.mk`.
- The common device tree's `common.mk` also inherits `vendor/oneplus/sm8350-common/sm8350-common-vendor.mk`, and `BoardConfigCommon.mk` includes the matching vendor BoardConfig. The local manifest includes `Debarpan102/proprietary_vendor_oneplus_sm8350-common` on branch `seventeen`.
- The kernel repository contains `arch/arm64/configs/vendor/oplus_yupik_QGKI.config` with `CONFIG_ARCH_YUPIK=y`, and `arch/arm64/configs/vendor/lahaina-qgki_defconfig` with `CONFIG_ARCH_LAHAINA=y`.
- The proprietary vendor repository has an `ice-vendor.mk` on branch `seventeen`.

## Other findings requiring work before a real build

1. **Overlay inspection:** the `overlay-yaap` folder contains three resource overlays: SystemUI burn-in protection, Settings face-enrollment configuration, and Aperture auxiliary-camera/video configurations. These resources look like device configuration rather than obviously YAAP-only product code. Keep them for now; validate the resource names and behavior against DerpFest Android 17 before renaming or changing paths.
2. **Android 17 compatibility is unproven.** Branch names do not prove Soong, SELinux, VINTF, HAL, kernel, or vendor compatibility.
3. **VINTF and HAL compatibility are not fully verified.** Check device and ODM manifests, framework compatibility matrices, vendor HAL versions, init rc files, and SELinux policy against the DerpFest 17 base.
4. **Proprietary source paths:** a static comparison of `ice-vendor.mk` against the proprietary vendor repository tree found all 617 unique `PRODUCT_COPY_FILES` source paths in the manifest. This confirms source-path presence in Git, not that every destination is correct or that blobs work on Android 17.
5. **Device-local paths:** the audio XMLs, media profiles, display config XML, and `init.oplus_ice.rc` referenced in `device.mk` exist in the device tree.
6. **Product identity needs device-side validation.** `derp_ice.mk` sets product/device/brand/model and GMS client ID, but the model and release identity must be checked against a verified stock build for this exact device.
7. **Duplicate copy entry fixed:** removed the second identical `media/media_profiles_vendor.xml` mapping from `device.mk`; the original source/destination mapping remains.

## Next safe engineering milestone

First resolve the chipset/common-tree/kernel mismatch using verified stock device information and a genuinely matching common tree. The inherited common tree is specifically `sm8350`/Lahaina, and its kernel build config is `build.config.msm.lahaina`; that is consistent with the owner-stated Lahaina target, but does not by itself prove the declared RMX3461 hardware identity or the Yupik device fragment is compatible. Only then audit every `PRODUCT_COPY_FILES` source, overlays, VINTF, proprietary blobs and SELinux, run `lunch derp_ice-userdebug`, and attempt a full build on a runner with sufficient disk/RAM. Do not label this port build-ready until a complete compile and hardware validation pass.

## Safety

This tree declares Realme RMX3461 codename `ice`. It is not the OnePlus 15R. Do not flash images built from this tree to a different device.
