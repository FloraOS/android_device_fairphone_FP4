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

AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    odm \
    recovery \
    vendor

# Radio/modem A/B partitions
AB_OTA_PARTITIONS +=\
    abl \
    aop \
    bluetooth \
    core_nhlos \
    devcfg \
    dsp \
    featenabler \
    hyp \
    imagefv \
    keymaster \
    modem \
    multiimgoem \
    qupfw \
    tz \
    uefisecapp \
    xbl \
    xbl_config


# Adreno
BOARD_USES_ADRENO := true


# Enable AVB 2.0
BOARD_AVB_ENABLE := true


# Chain partition for system
BOARD_AVB_VBMETA_SYSTEM := system
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2


# Audio
AUDIO_FEATURE_ENABLED_AHAL_EXT := false
AUDIO_FEATURE_ENABLED_COMPRESS_VOIP := false
AUDIO_FEATURE_ENABLED_DTS_EAGLE := false
AUDIO_FEATURE_ENABLED_EXTENDED_COMPRESS_FORMAT := true
AUDIO_FEATURE_ENABLED_EXTN_FORMATS := true
AUDIO_FEATURE_ENABLED_FM_POWER_OPT := false
AUDIO_FEATURE_ENABLED_HDMI_SPK := true
AUDIO_FEATURE_ENABLED_HW_ACCELERATED_EFFECTS := false
AUDIO_FEATURE_ENABLED_PROXY_DEVICE := true
AUDIO_FEATURE_ENABLED_SSR := false
BOARD_USES_ALSA_AUDIO := true
USE_CUSTOM_AUDIO_POLICY := 1

AUDIO_FEATURE_ENABLED_DLKM := true
AUDIO_FEATURE_ENABLED_DYNAMIC_LOG := false
AUDIO_FEATURE_ENABLED_GEF_SUPPORT := true
AUDIO_FEATURE_ENABLED_INSTANCE_ID := true
AUDIO_FEATURE_ENABLED_SVA_MULTI_STAGE := true
BOARD_SUPPORTS_QAHW := false
BOARD_SUPPORTS_SOUND_TRIGGER := true
TARGET_USES_QCOM_MM_AUDIO := true

BOARD_SUPPORTS_OPENSOURCE_STHAL := true

ifneq ($(QCPATH),)
AUDIO_FEATURE_ENABLED_DYNAMIC_LOG := true
AUDIO_FEATURE_ENABLED_SSR := true
endif


# Bluetooth
BOARD_ANT_WIRELESS_DEVICE := "qualcomm-hidl"
BOARD_HAVE_BLUETOOTH := true


# Board
BOARD_EXT4_SHARE_DUP_BLOCKS := true
TARGET_BOOTLOADER_BOARD_NAME := FP4
TARGET_NO_BOOTLOADER := false
TARGET_USES_UEFI := true


# Boot partition
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x06000000


# Display Density
TARGET_SCREEN_DENSITY := 420


# DTBO partition
BOARD_DTBOIMG_PARTITION_SIZE := 0x0800000


# File system
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)

TARGET_FS_CONFIG_GEN := $(FP_PATH)/configs/config.fs


# GPS
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := default


# Graphics
MAX_EGL_CACHE_KEY_SIZE := 12*1024
MAX_EGL_CACHE_SIZE := 2048*1024
MAX_VIRTUAL_DISPLAY_DIMENSION := 4096
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
SF_WCG_COMPOSITION_DATA_SPACE := 143261696
TARGET_FORCE_HWC_FOR_VIRTUAL_DISPLAYS := true
TARGET_HAS_HDR_DISPLAY := true
TARGET_HAS_WIDE_COLOR_DISPLAY := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USES_COLOR_METADATA := true
TARGET_USES_DISPLAY_RENDER_INTENTS := true
TARGET_USES_DRM_PP := true
TARGET_USES_GRALLOC1 := true
TARGET_USES_GRALLOC4 := true
TARGET_USES_HWC2 := true
TARGET_USES_ION := true
TARGET_USES_NEW_ION_API := true
TARGET_USES_QCOM_DISPLAY_BSP := true
TARGET_USES_QTI_MAPPER_2_0 := true
TARGET_USES_QTI_MAPPER_EXTENSIONS_1_1 := true
TARGET_USE_COLOR_MANAGEMENT := true


# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml
DEVICE_MANIFEST_FILE := $(FP_PATH)/manifest.xml
DEVICE_MATRIX_FILE   := $(FP_PATH)/compatibility_matrix.xml
ODM_MANIFEST_FILES   := $(FP_PATH)/manifest-qva.xml


# Kernel
BOARD_KERNEL_BASE        := 0x00000000
BOARD_KERNEL_PAGESIZE    := 4096
BOARD_KERNEL_SEPARATED_DTBO := true
BOARD_KERNEL_TAGS_OFFSET := 0x01E00000
BOARD_RAMDISK_OFFSET     := 0x02000000
KERNEL_TO_BUILD_ROOT_OFFSET := ../../
TARGET_COMPILE_WITH_MSM_KERNEL := true
TARGET_KERNEL_VERSION ?= 4.19
TARGET_KERNEL_SOURCE ?= kernel/msm-$(TARGET_KERNEL_VERSION)
# Disable appended dtb.
TARGET_KERNEL_APPEND_DTB := false
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(abspath .)/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_NO_KERNEL := false
TARGET_USES_UNCOMPRESSED_KERNEL := false

BOARD_KERNEL_CMDLINE := androidboot.console=ttyMSM0
BOARD_KERNEL_CMDLINE += androidboot.hardware=qcom
BOARD_KERNEL_CMDLINE += androidboot.memcg=1
BOARD_KERNEL_CMDLINE += androidboot.usbcontroller=a600000.dwc3
BOARD_KERNEL_CMDLINE += cgroup_disable=pressure
BOARD_KERNEL_CMDLINE += cgroup.memory=nokmem,nosocket
BOARD_KERNEL_CMDLINE += earlycon=msm_geni_serial,0x888000
BOARD_KERNEL_CMDLINE += loop.max_part=7
BOARD_KERNEL_CMDLINE += lpm_levels.sleep_disabled=1
BOARD_KERNEL_CMDLINE += msm_rtb.filter=0x237
BOARD_KERNEL_CMDLINE += service_locator.enable=1
BOARD_KERNEL_CMDLINE += swiotlb=2048
BOARD_KERNEL_CMDLINE += video=vfb:640x400,bpp=32,memsize=3072000
ifneq (,$(filter eng,$(TARGET_BUILD_VARIANT)))
BOARD_KERNEL_CMDLINE += console=ttyMSM0,115200,n8
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
endif

#Enable dtb in boot image and boot image header version 2 support.
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOTIMG_HEADER_VERSION)


# Kernel modules
BOARD_VENDOR_KERNEL_MODULES := \
    $(KERNEL_MODULES_OUT)/audio_adsp_loader.ko \
    $(KERNEL_MODULES_OUT)/audio_apr.ko \
    $(KERNEL_MODULES_OUT)/audio_bolero_cdc.ko \
    $(KERNEL_MODULES_OUT)/audio_hdmi.ko \
    $(KERNEL_MODULES_OUT)/audio_machine_lito.ko \
    $(KERNEL_MODULES_OUT)/audio_mbhc.ko \
    $(KERNEL_MODULES_OUT)/audio_native.ko \
    $(KERNEL_MODULES_OUT)/audio_pinctrl_lpi.ko \
    $(KERNEL_MODULES_OUT)/audio_platform.ko \
    $(KERNEL_MODULES_OUT)/audio_q6.ko \
    $(KERNEL_MODULES_OUT)/audio_q6_notifier.ko \
    $(KERNEL_MODULES_OUT)/audio_q6_pdr.ko \
    $(KERNEL_MODULES_OUT)/audio_rx_macro.ko \
    $(KERNEL_MODULES_OUT)/audio_snd_event.ko \
    $(KERNEL_MODULES_OUT)/audio_stub.ko \
    $(KERNEL_MODULES_OUT)/audio_swr.ko \
    $(KERNEL_MODULES_OUT)/audio_swr_ctrl.ko \
    $(KERNEL_MODULES_OUT)/audio_tx_macro.ko \
    $(KERNEL_MODULES_OUT)/audio_usf.ko \
    $(KERNEL_MODULES_OUT)/audio_va_macro.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd937x.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd937x_slave.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd938x.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd938x_slave.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd9xxx.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd_core.ko \
    $(KERNEL_MODULES_OUT)/audio_wsa881x.ko \
    $(KERNEL_MODULES_OUT)/audio_wsa883x.ko \
    $(KERNEL_MODULES_OUT)/audio_wsa_macro.ko \
    $(KERNEL_MODULES_OUT)/lcd.ko \
    $(KERNEL_MODULES_OUT)/llcc_perfmon.ko \
    $(KERNEL_MODULES_OUT)/mpq-adapter.ko \
    $(KERNEL_MODULES_OUT)/mpq-dmx-hw-plugin.ko

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
    ifeq (,$(findstring perf_defconfig, $(KERNEL_DEFCONFIG)))
        BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/atomic64_test.ko
        BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/lkdtm.ko
        BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/locktorture.ko
        BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/rcutorture.ko
        BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/test_user_copy.ko
        BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/torture.ko
    endif
endif

# Data
BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/rmnet_shs.ko
BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/rmnet_perf.ko

# Wifi
BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/qca_cld3_wlan.ko


# Metadata partition
# Define BOARD_USES_METADATA_PARTITION to create metadata mount point in system image
BOARD_USES_METADATA_PARTITION := true


# ODM partition
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_ODM := odm


# Others
BOARD_DO_NOT_STRIP_VENDOR_MODULES := true
BOARD_USES_GENERIC_AUDIO := true


# Persist partition
BOARD_PERSISTIMAGE_FILE_SYSTEM_TYPE := ext4


# Power
TARGET_USES_INTERACTION_BOOST := true


# Recovery
# Enable DTBO for recovery image
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x06000000
TARGET_RECOVERY_FSTAB := $(FP_PATH)/rootdir/etc/recovery_AB_variant.fstab
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 100


# Sensors
USE_SENSOR_MULTI_HAL := true


# SEPolicy
include device/qcom/sepolicy_vndr/SEPolicy.mk
BOARD_SEPOLICY_DIRS += \
    $(FP_PATH)/sepolicy/vendor


# Super partition
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 6438256640
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_SUPER_PARTITION_SIZE := 6442450944

BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    odm \
    vendor


# Treble
BOARD_SYSTEMSDK_VERSIONS := $(SHIPPING_API_LEVEL)
PRODUCT_FULL_TREBLE_OVERRIDE := true


# Userdata partition
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USERDATAIMAGE_PARTITION_SIZE := 26843545600


# Vendor partition
ENABLE_VENDOR_IMAGE := true
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor


# VNDK
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
BOARD_VNDK_VERSION := current


# Wifi
BOARD_WLAN_DEVICE := qcwcn
BOARD_HAS_QCOM_WLAN := true
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
CONFIG_ACS := true
CONFIG_IEEE80211AC := true
HOSTAPD_VERSION := VER_0_8_X
TARGET_USES_ICNSS_QMI := true
WIFI_DRIVER_BUILT := qca_cld3
WIFI_DRIVER_DEFAULT := qca_cld3
WIFI_DRIVER_INSTALL_TO_KERNEL_OUT := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wlan"
WIFI_DRIVER_STATE_OFF := "OFF"
WIFI_DRIVER_STATE_ON := "ON"


# Vendor-specific definitions
-include vendor/fairphone/fp4/BoardConfigVendor.mk
