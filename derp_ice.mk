#
# Copyright (C) 2026 The ice-17 project
# SPDX-License-Identifier: Apache-2.0
#

# Base Android products.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device configuration.
$(call inherit-product, device/realme/ice/device.mk)

# DerpFest Android 17 currently uses the Lineage-compatible vendor config
# provided by the DerpFest manifest at vendor/lineage.
$(call inherit-product, vendor/lineage/config/common_mobile_full.mk)
$(call inherit-product, vendor/lineage/config/telephony.mk)

# Device identity. Keep these values aligned with the actual device.
PRODUCT_NAME := derp_ice
PRODUCT_DEVICE := ice
PRODUCT_MANUFACTURER := realme
PRODUCT_BRAND := realme
PRODUCT_MODEL := RMX3461
PRODUCT_GMS_CLIENTID_BASE := android-oppo

# Boot animation resolution.
TARGET_BOOT_ANIMATION_RES := 1080

# Intentionally do not carry over YAAP-only product flags or the Android 13
# stock fingerprint override from yaap_ice.mk. Further device-specific
# properties must be verified against Android 17 before enabling a build.
