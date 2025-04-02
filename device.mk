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


# Init
PRODUCT_PACKAGES += \
    init.crda.sh \
    init.environ.rc \
    init.qti.dcvs.sh \
    init.target.rc \
    init.qcom.coex.sh \
    init.qcom.early_boot.sh \
    init.qcom.post_boot.sh \
    init.qcom.rc \
    init.recovery.qcom.rc \
    init.qcom.factory.rc \
    init.qcom.sdio.sh \
    init.qcom.sh \
    init.qcom.class_core.sh \
    init.class_main.sh \
    init.qcom.usb.rc \
    init.qcom.usb.sh \
    init.qcom.efs.sync.sh \
    init.qti.early_init.sh \
    init.qti.ufs.rc \
    ueventd.qcom.rc \
    qca6234-service.sh \
    init.mdm.sh \
    fstab.default

# Fstab for ramdisk
PRODUCT_COPY_FILES += \
    $(FP_PATH)/rootdir/etc/fstab_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.default

PRODUCT_PACKAGES_DEBUG += \
    init.qcom.debug.sh \
    init.qcom.debug-sdm660.sh \
    init.qcom.debug-sdm710.sh \
    init.qcom.test.rc \
    init.qti.debug-msmnile-apps.sh \
    init.qti.debug-msmnile-modem.sh \
    init.qti.debug-msmnile-slpi.sh \
    init.qti.debug-talos.sh \
    init.qti.debug-msmnile.sh \
    init.qti.debug-kona.sh \
    init.qti.debug-lito.sh \
    init.qti.debug-atoll.sh \
    init.qti.debug-trinket.sh \
    init.qti.debug-bengal.sh \
    init.qti.debug-khaje.sh \
    init.qti.usb.debug.sh


# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/FP4/$(KERNEL_MODULES_INSTALL)/lib/modules


# include additional QCOM build utilities
include $(FP_PATH)/utils.mk
