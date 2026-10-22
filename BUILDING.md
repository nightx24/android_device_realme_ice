# Realme ice / DerpFest Android 17 build notes

## Target

- Device codename: `ice`
- Model declared by this device tree: Realme RMX3461
- Working branch in this repository: `ice-17`
- Device-source branches: `seventeen`
- ROM manifest: [DerpFest-AOSP/android_manifest, branch 17](https://github.com/DerpFest-AOSP/android_manifest/tree/17)
- DerpFest vendor repository: [DerpFest-AOSP/android_vendor_derpfest, branch 17](https://github.com/DerpFest-AOSP/android_vendor_derpfest/tree/17)
- Port review: [ANDROID17_PORT_AUDIT.md](ANDROID17_PORT_AUDIT.md)

**Do not flash this build to a OnePlus 15R or any other model.** This device tree identifies Realme RMX3461 and has not been hardware-tested as part of this work.

## Changes on `ice-17`

- Added `build/local_manifests/ice.xml` for the five existing device, vendor, common, hardware, and kernel repositories.
- Added an initial `derp_ice.mk` product definition using the DerpFest Android 17 vendor configuration path.
- Updated `AndroidProducts.mk` to expose `derp_ice-user`, `derp_ice-userdebug`, and `derp_ice-eng`.
- Added a GitHub Actions preflight to check source branches, local-manifest XML, and product metadata.
- Added a source audit documenting confirmed manifest paths and unresolved compatibility checks.

The product makefile is an **initial port, not a compile-tested configuration**.

## Remaining blockers

1. `device.mk` still includes `overlay-yaap`. Its resources need review for YAAP-specific assumptions and Android 17 compatibility before deciding whether to retain, adapt, or remove them.
2. Confirm the device and SM8350 common trees are compatible with the exact DerpFest Android 17 manifest revisions.
3. Validate proprietary vendor blobs, camera/audio/display dependencies, VINTF, partition sizes, kernel configuration, module loading, and SELinux policy.
4. Resolve all product copy-file sources and check all referenced overlays/configs after the source tree is synced.
5. No boot, recovery, OTA, or ROM image has been compiled or tested on hardware.

## Source setup (on a suitably provisioned build runner)

This project does not require a personal PC if you have access to a cloud runner with enough storage. A standard GitHub-hosted runner generally does **not** have enough free disk for a complete Android checkout and build; this repository's preflight does not attempt the full build.

On a runner with several hundred GB of available disk and sufficient RAM/CPU:

```bash
repo init -u https://github.com/DerpFest-AOSP/android_manifest.git -b 17
mkdir -p .repo/local_manifests
curl -fL https://raw.githubusercontent.com/nightx24/android_device_realme_ice/ice-17/build/local_manifests/ice.xml -o .repo/local_manifests/ice.xml
repo sync -c -j2
```

The command downloads the tracked local manifest directly, so you do not need a prior device-tree checkout.

After sync, verify that the repo manifest resolves every project and that `derp_ice-userdebug` is listed by the build environment. Do not assume a successful sync proves buildability. Run the build only after auditing the YAAP overlays and device-specific compatibility issues.

## Build capacity and safety

A full Android source checkout and output commonly consume hundreds of GB. Ordinary GitHub-hosted runners are typically too small; larger hosted runners depend on account/org availability and configuration. Do not add access tokens, cloud credentials, or signing keys to the repository to work around resource limits.

Any generated image must be verified against the exact RMX3461 device, partition layout, bootloader state, and install procedure. Do not flash untested images.
