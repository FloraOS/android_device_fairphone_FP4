# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 FairPhone B.V.

# config.mk
#
# Product-specific compile-time definitions.
#

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a9


# A/B partition configs
AB_OTA_UPDATER := true

# A/B partition configs
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    odm \
    recovery \
    vendor


# Enable AVB 2.0
BOARD_AVB_ENABLE := true


# Board
BOARD_EXT4_SHARE_DUP_BLOCKS := true
TARGET_BOOTLOADER_BOARD_NAME := FP4
TARGET_NO_BOOTLOADER := false
TARGET_USES_UEFI := true


# Boot partition
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x06000000


# DTBO partition
BOARD_DTBOIMG_PARTITION_SIZE := 0x0800000


# File system
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)

TARGET_FS_CONFIG_GEN := $(FP_PATH)/configs/config.fs


# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml
DEVICE_MANIFEST_FILE := $(FP_PATH)/manifest.xml
DEVICE_MATRIX_FILE   := $(FP_PATH)/compatibility_matrix.xml


# Metadata partition
# Define BOARD_USES_METADATA_PARTITION to create metadata mount point in system image
BOARD_USES_METADATA_PARTITION := true


# ODM partition
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_ODM := odm


# Others
BOARD_USES_GENERIC_AUDIO := true


# Persist partition
BOARD_PERSISTIMAGE_FILE_SYSTEM_TYPE := ext4


# Recovery
# Enable DTBO for recovery image
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x06000000
TARGET_RECOVERY_FSTAB := $(FP_PATH)/rootdir/etc/recovery_AB_variant.fstab


# Super partition
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 6438256640
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_SUPER_PARTITION_SIZE := 6442450944

 Super partition
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    odm \
    vendor

# Userdata partition
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USERDATAIMAGE_PARTITION_SIZE := 26843545600


# Vendor partition
ENABLE_VENDOR_IMAGE := true
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor
