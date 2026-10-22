# Realme ice / DerpFest Android 17 build notes

## Target and source

- Device codename: `ice`
- Model declared by the current device tree: Realme RMX3461
- Working integration branch in this repository: `ice-17`
- Device-source branches currently referenced by the local manifest: `seventeen`
- ROM manifest: `https://github.com/DerpFest-AOSP/android_manifest`, branch `17`
- Manifest base revision declares Android `17.0.0_r1` and a LineageOS `lineage-24.0` default revision.

**Do not flash this build to a OnePlus 15R.** The tree identifies Realme RMX3461 and is not a OnePlus 15R device tree.

## Local manifest

Copy `build/local_manifests/ice.xml` to `.repo/local_manifests/ice.xml` after initializing the DerpFest manifest and before `repo sync`.

It maps the five existing device repositories to the paths expected by the device tree:
- `device/realme/ice`
- `vendor/realme/ice`
- `device/oneplus/sm8350-common`
- `hardware/oplus`
- `kernel/oneplus/sm8350`

## Current blockers before a safe ROM build

This branch is not yet build-ready. The following are intentionally **not** changed automatically:

1. `AndroidProducts.mk` still advertises `yaap_ice`, and `yaap_ice.mk` inherits YAAP configuration. DerpFest product configuration must be ported and verified against the Android 17 DerpFest vendor tree.
2. `device.mk` includes `overlay-yaap`; inspect/replace YAAP-specific overlay resources and packages for compatibility with DerpFest.
3. `BoardConfig.mk` includes the SM8350 common tree and a kernel config. Confirm the common tree, kernel source, vendor blobs, VINTF, SELinux policy, and partition definitions are compatible with the exact Android 17 source revision.
4. The source branch name `seventeen` is only a branch label. Existence checks do not prove that every repository actually compiles against Android 17.
5. No boot, recovery, or ROM image has been built or tested on hardware.

## Build capacity

A complete Android ROM source checkout plus output commonly needs hundreds of GB of disk space and substantial RAM/CPU. Standard GitHub-hosted runners do not provide enough persistent/free disk for a normal full Android source build. This repository therefore does not launch a speculative full build on every push. Use a GitHub-hosted larger runner only if the account/org has one available with adequate disk, or another explicitly provisioned runner. Do not add cloud credentials or secrets to the workflow just to bypass runner limits.

## Next validation sequence

1. Run the `Ice 17 ROM Preflight` workflow.
2. Confirm all five source refs and the DerpFest manifest branch are found.
3. Port the product makefile and remove/replace YAAP-only overlays and package references.
4. Add a build job only after a runner with sufficient storage is available; build the exact lunch target and archive images/logs.
5. Review build logs and verify device-specific boot/recovery images before any installation. Never flash an untested image.
