#
# Copyright (C) 2021-2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Base Android products.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
TARGET_SUPPORTS_OMX_SERVICE := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Realme RMX3461 device configuration.
$(call inherit-product, device/realme/ice/device.mk)

# LineageOS phone configuration.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_ice
PRODUCT_DEVICE := ice
PRODUCT_MANUFACTURER := realme
PRODUCT_BRAND := realme
PRODUCT_MODEL := RMX3461
PRODUCT_GMS_CLIENTID_BASE := android-oppo

# Keep Android 13 stock fingerprint overrides out of the Android 17 product
# until the exact installed firmware fingerprint is verified.
