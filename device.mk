# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 FairPhone B.V.

FP_PATH := device/fairphone/FP4


# Inherit Virtual AB configs
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

# Inherit GSI keys to first stage ramdisk
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)

# Inherit generic AOSP content for telephony based 64-bit devices
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)


# API level the device was shipped
PRODUCT_SHIPPING_API_LEVEL := 30
SHIPPING_API_LEVEL := 30


PRODUCT_BRAND := Fairphone
PRODUCT_DEVICE := FP4
PRODUCT_MANUFACTURER := Fairphone

TARGET_BOARD_PLATFORM := lito


# Build only specific images
PRODUCT_BUILD_BOOT_IMAGE := true
PRODUCT_BUILD_ODM_IMAGE := true
PRODUCT_BUILD_PRODUCT_IMAGE := false
PRODUCT_BUILD_RAMDISK_IMAGE := true
PRODUCT_BUILD_RECOVERY_IMAGE := true
PRODUCT_BUILD_SYSTEM_EXT_IMAGE := false
PRODUCT_BUILD_SYSTEM_IMAGE := false
PRODUCT_BUILD_USERDATA_IMAGE := false
PRODUCT_BUILD_VENDOR_IMAGE := true


# AB configurations
ENABLE_AB := true # Enable AB partitions by default
ENABLE_VIRTUAL_AB := true # Enable virtual AB configs by default


# Board platforms lists to be used for
# TARGET_BOARD_PLATFORM specific featurization
QCOM_BOARD_PLATFORMS += lito


# Display Properties
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi


# include additional QCOM build utilities
include $(FP_PATH)/utils.mk
