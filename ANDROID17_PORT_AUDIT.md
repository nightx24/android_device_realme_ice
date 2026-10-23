# Android 17 / DerpFest port audit — Realme RMX3461 (ice)

Status: static source audit only. This is not a successful Android build and does not certify a bootable image.

## Reference-port review: Lahaina base plus Yupik device fragment

The project uses the SM8350 common tree, whose `BoardConfigCommon.mk` sets `TARGET_BOARD_PLATFORM := lahaina` and `TARGET_KERNEL_CONFIG := vendor/lahaina-qgki_defconfig`. The device tree then appends `vendor/oplus_yupik_QGKI.config`.

I reviewed the reference maintainer's Realme ice tree and kernel history. Their [YAAP bring-up commit](https://github.com/Debarpan102/android_device_realme_ice/commit/52892ace44eaf7995f4c6add691b6babebc676c5) selects `yaap_ice`, inherits YAAP product config and switches the overlay path to `overlay-yaap`. Their [common-kernel switch](https://github.com/Debarpan102/android_device_realme_ice/commit/45e25bac0e0ef1a05b701e178a627ebb4bd75f05) replaces the standalone RMX3461 kernel source with the common-kernel setup while retaining `TARGET_KERNEL_CONFIG += vendor/oplus_yupik_QGKI.config`. The fragment was introduced explicitly for Yupik devices and Realme Q3s touchpanel support in [this kernel commit](https://github.com/Debarpan102/kernel_oneplus_sm8350/commit/ad3dcbc0c7090cc56ae962eef0374b6554bde31f); a later commit adds the OPlus/ST21 NFC drivers [here](https://github.com/Debarpan102/kernel_oneplus_sm8350/commit/bb7a3d6e5f93354d09f174d0bf9ad35ed7d56eb2).

Based on that concrete reference, the device fragment **must retain `CONFIG_ARCH_YUPIK=y`** alongside its NFC, Ilitek touchpanel, and Wi-Fi options; I restored it in the `nightx24/kernel_oneplus_sm8350` branch. Do not interpret the two config files as a choice between Lahaina and Yupik: this reference port intentionally uses the Lahaina base defconfig plus the Yupik device fragment. The GitHub Actions kernel-config job now runs the actual Kconfig merge and `olddefconfig`, and verifies the expected Lahaina/Yupik, NFC, Ilitek touchpanel, and QCA6750 symbols in the resolved `.config`. This validates configuration resolution only; it does not compile a kernel image.

The reference repository has a `YAAP Initial Bringup` commit, but its device repository currently exposes no GitHub Actions workflow runs or releases through the public API. The commit history is useful implementation evidence, but it does not by itself prove a particular commit produced a bootable image or identify which exact ROM build was tested.

## Confirmed from source

- **Local manifest branch mismatch fixed:** the device project now syncs `refs/heads/ice-17`, matching the active port branch. Previously it requested `refs/heads/seventeen`, which could silently sync a different revision despite building from the `ice-17` branch in the preflight checkout. The workflow now checks the active branch and validates this manifest revision.

- DerpFest manifest branch `17` has a `snippets/derp.xml` manifest that maps `vendor/lineage` to the `android_vendor_derpfest` project.
- In that vendor tree, `config/common_mobile_full.mk` inherits `vendor/lineage/config/common_mobile.mk`; `config/telephony.mk` exists. The current `derp_ice.mk` inheritance paths therefore match the inspected DerpFest source layout.
- The device tree's `device.mk` inherits `device/oneplus/sm8350-common/common.mk` and `vendor/realme/ice/ice-vendor.mk`.
- The common device tree's `common.mk` also inherits `vendor/oneplus/sm8350-common/sm8350-common-vendor.mk`, and `BoardConfigCommon.mk` includes the matching vendor BoardConfig. The local manifest includes `Debarpan102/proprietary_vendor_oneplus_sm8350-common` on branch `seventeen`.
- The kernel fork contains `arch/arm64/configs/vendor/oplus_yupik_QGKI.config` with `CONFIG_ARCH_YUPIK=y` plus device-specific NFC/touchpanel/Wi-Fi settings, and `vendor/lahaina-qgki_defconfig` with `CONFIG_ARCH_LAHAINA=y`. The Yupik setting was restored to match the reference tree. The `nightx24` fork has local commits not present in Debarpan’s branch; review diffs before syncing either direction. The local manifest continues to use the `nightx24` fork.
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
