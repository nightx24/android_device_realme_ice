# Realme ice / DerpFest Android 17 build notes

## Target

- Device codename: `ice`
- Model declared by this device tree: Realme RMX3461
- Working branch in this repository: `ice-17`
- Device-source branches: `seventeen`
- ROM manifest: [DerpFest-AOSP/android_manifest, branch 17](https://github.com/DerpFest-AOSP/android_manifest/tree/17)
- DerpFest vendor repository: [DerpFest-AOSP/android_vendor_derpfest, branch 17](https://github.com/DerpFest-AOSP/android_vendor_derpfest/tree/17)
- Port review: [ANDROID17_PORT_AUDIT.md](ANDROID17_PORT_AUDIT.md)

**Kernel config reference reviewed:** the established Realme ice YAAP tree also uses the Lahaina base defconfig and appends `vendor/oplus_yupik_QGKI.config`. The GitHub Actions kernel-config job now successfully merges the two configurations and checks the expected Lahaina/Yupik, NFC, Ilitek touchpanel, and QCA6750 symbols after `olddefconfig`. Keep `CONFIG_ARCH_YUPIK=y` and the device-specific settings in that fragment. See [the YAAP bring-up commit](https://github.com/Debarpan102/android_device_realme_ice/commit/52892ace44eaf7995f4c6add691b6babebc676c5), [the common-kernel switch](https://github.com/Debarpan102/android_device_realme_ice/commit/45e25bac0e0ef1a05b701e178a627ebb4bd75f05), and the [reference-port audit](ANDROID17_PORT_AUDIT.md). This is configuration validation, not kernel image or ROM compilation.

**Do not flash this build to a OnePlus 15R or any other model.** This device tree identifies Realme RMX3461 and has not been hardware-tested as part of this work.

## Changes on `ice-17`

- Added `build/local_manifests/ice.xml` for the device, Realme vendor, SM8350 common device, SM8350 common proprietary vendor, OPlus hardware, and kernel repositories.
- Added an initial `derp_ice.mk` product definition using the DerpFest Android 17 vendor configuration path.
- Updated `AndroidProducts.mk` to expose `derp_ice-user`, `derp_ice-userdebug`, and `derp_ice-eng`.
- Added a GitHub Actions preflight to check source branches, local-manifest XML, product metadata, DerpFest vendor config inheritance, VINTF XML, and kernel config fragment presence.
- Added a source audit documenting the reference YAAP bring-up and its Lahaina-base-plus-Yupik-fragment kernel configuration.

The product makefile is an **initial port, not a compile-tested configuration**.

## Remaining blockers

1. Compare the merged kernel `.config` against a verified stock RMX3461 config, if available, and eventually compile the kernel image.
2. `device.mk` still includes `overlay-yaap`. Review its resources for YAAP-specific assumptions and Android 17 compatibility before deciding whether to retain, adapt, or remove them.
3. Confirm the device and common trees are compatible with the exact DerpFest Android 17 manifest revisions.
4. Validate proprietary vendor blobs, camera/audio/display dependencies, VINTF/HAL compatibility, partition sizes, module loading, and SELinux policy.
5. After a full source sync, run actual Android product make/Soong checks and resolve any compile errors.
6. No boot, recovery, OTA, or ROM image has been compiled or tested on hardware.

## Source setup (on a suitably provisioned build runner)

This project does not require a personal PC if you have access to a cloud runner with enough storage. A standard GitHub-hosted runner generally does **not** have enough free disk for a complete Android checkout and build; this repository's preflight does not attempt the full build.

**Do not run a full build until the kernel configuration and remaining compatibility checks are resolved.** After that, on a runner with several hundred GB of available disk and sufficient RAM/CPU:

```bash
repo init -u https://github.com/DerpFest-AOSP/android_manifest.git -b 17
mkdir -p .repo/local_manifests
curl -fL https://raw.githubusercontent.com/nightx24/android_device_realme_ice/ice-17/build/local_manifests/ice.xml -o .repo/local_manifests/ice.xml
repo sync -c -j2
```

The command downloads the tracked local manifest directly, so you do not need a prior device-tree checkout.

After sync, verify that the repo manifest resolves every project and that `derp_ice-userdebug` is listed by the build environment. A successful sync does not prove buildability.

## Build capacity and safety

A full Android source checkout and output commonly consume hundreds of GB. Ordinary GitHub-hosted runners are typically too small; larger hosted runners depend on account/org availability and configuration. Do not add access tokens, cloud credentials, or signing keys to the repository to work around resource limits.

Any generated image must be verified against the exact RMX3461 device, partition layout, bootloader state, and install procedure. Do not flash untested images.

## Latest build milestone (2026-10-23)

The GitHub Actions kernel-image job completed successfully on run [39893491998](https://github.com/nightx24/android_device_realme_ice/actions/runs/39893491998). It produced an arm64 kernel `Image` and a build log. The output is a raw kernel image only: it is not a `boot.img`, installer ZIP, OTA, or complete ROM.

The common BoardConfig declares boot header version 3, a 4096-byte kernel page size, an A/B layout, and separate `boot`, `vendor_boot`, and `dtbo` partitions. Before constructing a flashable boot image, preserve the matching ramdisk and boot metadata from a verified RMX3461 build. Do not use a boot image from the user's separate OnePlus 15R or from an unrelated device.


### Boot-image layout details checked against the shared BoardConfig

| Setting | Source value |
|---|---|
| Boot header | v3 |
| Kernel image name | `Image` |
| Kernel page size | 4096 bytes |
| DTBO | Separate image (`BOARD_KERNEL_SEPARATED_DTBO := true`) |
| DTB in boot image | Enabled (`BOARD_INCLUDE_DTB_IN_BOOTIMG := true`) |
| Boot image partition limit | 201,326,592 bytes |
| Vendor boot partition limit | 201,326,592 bytes |
| DTBO partition limit | 25,165,824 bytes |
| Recovery resources | Moved to `vendor_boot` |

These are build-tree declarations, not measurements of the installed phone's actual partitions. Verify them against the exact RMX3461 firmware images before packaging. The reference device-tree repository currently has no published GitHub Releases and no GitHub Actions run artifacts to retrieve as a known-good boot-image set. Therefore, do not substitute images from a different device or unrelated build.

### Next packaging gate

Obtain matching `boot.img`, `vendor_boot.img`, and `dtbo.img` from the known-working RMX3461 YAAP build or matching stock firmware, then inspect their headers and contents. Do not create or flash a boot image until the source image layout, ramdisk arrangement, command line, DTB/DTBO handling, and partition sizes are confirmed. A successful kernel compile does not establish hardware bootability.

A full DerpFest Android 17 build is still outstanding. The standard GitHub-hosted runner used for kernel CI does not provide the storage capacity normally needed for a complete Android source checkout and build.

### Firmware and boot-component investigation (2026-10-23)

The target phone is unrooted, so normal Android apps cannot read the protected raw boot partitions. Do not attempt to write to or dump block devices through an unprivileged shell. The preferred no-root route is to obtain the exact RMX3461 stock firmware package (or a verified full OTA package) and extract its images in a controlled build environment. If it contains `payload.bin`, use a reputable payload extractor to inspect the image set and compare build fingerprints / firmware versions before using any component.

Research found an archived AlphaDroid OTA index for RMX3461 that points to `AlphaDroid-20230316-RMX3461-vanilla-v1.2.1.zip` (Android 13-era, 2023). It is useful evidence that public RMX3461 ROM packages existed, but it is old and is **not approved as the source of boot components** for the currently installed YAAP build or this Android 17 port. Index: https://github.com/AlphaDroid-devices/OTA/blob/main/RMX3461.json .

Research also found a public RMX3461 TWRP device tree with `prebuilt/dtbo.img` and a prebuilt kernel, but no matching `boot.img` + `vendor_boot.img` set was identified. A recovery-tree prebuilt DTBO alone does not establish matching firmware version, boot ramdisk, vendor boot modules, or AVB metadata, so it must not be treated as a complete or verified boot-image set: https://github.com/realme9se-trees/twrp_device_realme_RMX3461/tree/main/prebuilt .

**Current result:** no verified, version-matched stock firmware URL or complete boot-component set has been established yet. Continue searching for an official Realme RMX3461 package or a known-working YAAP release. Do not flash the raw kernel image or combine it with unverified boot components.
