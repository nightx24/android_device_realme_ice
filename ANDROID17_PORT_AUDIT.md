# Android 17 / DerpFest port audit — Realme RMX3461 (ice)

Status: static source audit only. This is not a successful Android build and does not certify a bootable image.

## Lahaina target and remaining kernel-fragment question

The project owner has confirmed that **Lahaina is the intended platform**. Treat the inherited common tree's `TARGET_BOARD_PLATFORM := lahaina` and `vendor/lahaina-qgki_defconfig` as the intended base; do not switch the port to Yupik based only on the fragment name.

Kernel fragment adjustment made: `vendor/oplus_yupik_QGKI.config` no longer sets `CONFIG_ARCH_YUPIK=y`; the Lahaina base defconfig remains responsible for `CONFIG_ARCH_LAHAINA=y`. The fragment still retains its NFC, Ilitek touchpanel, and Wi-Fi settings. Comparing the project kernel fork with the reference [`Debarpan102/kernel_oneplus_sm8350`](https://github.com/Debarpan102/kernel_oneplus_sm8350/tree/seventeen) confirms the `nightx24` `seventeen` branch is one commit ahead, and the only branch difference is this fragment edit. That is why the local manifest should continue using the `nightx24` fork for now rather than switching to the reference branch, which still contains `CONFIG_ARCH_YUPIK=y`. This removes the direct architecture-symbol conflict, but the remaining driver selections and final merged `.config` still need a real kernel configuration run and device-source validation.

This is a **kernel config consistency check**, not evidence that the Lahaina common tree itself is wrong. Confirm the final merged `.config` and verify that the device tree, vendor blobs, and kernel sources all match the intended hardware before building or flashing.

## Confirmed from source

- **Local manifest branch mismatch fixed:** the device project now syncs `refs/heads/ice-17`, matching the active port branch. Previously it requested `refs/heads/seventeen`, which could silently sync a different revision despite building from the `ice-17` branch in the preflight checkout. The workflow now checks the active branch and validates this manifest revision.

- DerpFest manifest branch `17` has a `snippets/derp.xml` manifest that maps `vendor/lineage` to the `android_vendor_derpfest` project.
- In that vendor tree, `config/common_mobile_full.mk` inherits `vendor/lineage/config/common_mobile.mk`; `config/telephony.mk` exists. The current `derp_ice.mk` inheritance paths therefore match the inspected DerpFest source layout.
- The device tree's `device.mk` inherits `device/oneplus/sm8350-common/common.mk` and `vendor/realme/ice/ice-vendor.mk`.
- The common device tree's `common.mk` also inherits `vendor/oneplus/sm8350-common/sm8350-common-vendor.mk`, and `BoardConfigCommon.mk` includes the matching vendor BoardConfig. The local manifest includes `Debarpan102/proprietary_vendor_oneplus_sm8350-common` on branch `seventeen`.
- The kernel fork contains `arch/arm64/configs/vendor/oplus_yupik_QGKI.config` with device-specific NFC/touchpanel/Wi-Fi settings, and `arch/arm64/configs/vendor/lahaina-qgki_defconfig` with `CONFIG_ARCH_LAHAINA=y`. A branch comparison against `Debarpan102/kernel_oneplus_sm8350:seventeen` shows the fork’s sole extra commit removes `CONFIG_ARCH_YUPIK=y` from the device fragment. Keep the local manifest pointed at the fork until this change is upstreamed or otherwise preserved.
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

Next validate the retained NFC/touchpanel/Wi-Fi config options against the exact stock device kernel config and run the kernel's config merge to inspect the final `.config`. The inherited common tree is `sm8350`/Lahaina, and the kernel build config is `build.config.msm.lahaina`; this matches the owner-stated Lahaina target but does not prove the declared RMX3461 hardware identity or all driver selections. Then continue the VINTF, proprietary blob, overlay and SELinux audit before any full build. Do not label this port build-ready until a complete compile and hardware validation pass.

## Safety

This tree declares Realme RMX3461 codename `ice`. It is not the OnePlus 15R. Do not flash images built from this tree to a different device.
