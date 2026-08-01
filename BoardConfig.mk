# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024-2025 FairPhone B.V.

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
    product \
    recovery \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor

# Firmware partitions that must never be shipped inside an OTA ZIP.
#
# The whole boot chain (xbl/abl/tz/hyp/...) along with the modem, DSP and
# Bluetooth firmware is signed by Fairphone and is only ever updated through
# their official firmware releases. The remaining entries are scratch, log or
# runtime-populated areas (apdp, ddr, logfs, tunning, metadata) that carry no
# meaningful build output. Pushing our own copies of any of them through
# update_engine is at best rejected by the device and at worst unrecoverable.
#
# The images themselves are still built and still land in the RADIO/ directory
# of target_files.zip (see device/fairphone/fp4-proprietary/Android.mk), so
# fastboot flashing and factory image generation are unaffected. Only the A/B
# payload loses them: build/make/core/Makefile writes META/ab_partitions.txt out
# of AB_OTA_PARTITIONS, and that file is what ota_from_target_files packs.
FP4_OTA_EXCLUDED_PARTITIONS := \
    abl \
    aop \
    apdp \
    bluetooth \
    core_nhlos \
    ddr \
    devcfg \
    dsp \
    featenabler \
    hyp \
    imagefv \
    keymaster \
    logfs \
    metadata \
    modem \
    multiimgoem \
    qupfw \
    storsec \
    toolsfv \
    tunning \
    tz \
    uefisecapp \
    xbl \
    xbl_config


# Adreno
BOARD_USES_ADRENO := true


# Enable AVB 2.0
BOARD_AVB_ENABLE := true


# Broken flags
ifneq ($(QCPATH),)
BUILD_BROKEN_PREBUILT_ELF_FILES := true
BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true
BUILD_BROKEN_USES_BUILD_HOST_EXECUTABLE := true
BUILD_BROKEN_USES_BUILD_HOST_SHARED_LIBRARY := true
BUILD_BROKEN_USES_BUILD_HOST_STATIC_LIBRARY := true
endif


# Chain partition for the system-side images. All three live in the same chained
# vbmeta_system descriptor so a system-only OTA can re-sign them without
# touching the top level vbmeta that the bootloader verifies.
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2


# Audio
AUDIO_FEATURE_ENABLED_AHAL_EXT := false
AUDIO_FEATURE_ENABLED_COMPRESS_VOIP := false
AUDIO_FEATURE_ENABLED_DTS_EAGLE := false
# The extended compress API (compress_set_metadata, compress_get_metadata,
# compress_set_next_track_param) only exists in the CAF fork of
# external/tinycompress. The AOSP copy keeps it behind
# ENABLE_EXTENDED_COMPRESS_FORMAT, which cannot be switched on there because
# compress_set_next_track_param needs SNDRV_COMPRESS_SET_NEXT_TRACK_PARAM, a
# Qualcomm ioctl that bionic's scrubbed uapi headers do not carry. With the
# feature off the HAL falls back to the no-op macros in audio_extn.h, which
# costs gapless metadata on compress-offloaded playback and nothing else.
AUDIO_FEATURE_ENABLED_EXTENDED_COMPRESS_FORMAT := false
AUDIO_FEATURE_ENABLED_EXTN_FORMATS := true
AUDIO_FEATURE_ENABLED_EXTN_FLAC_DECODER := true
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
MM_AUDIO_ENABLED_FTM := true
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
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_NO_KERNEL := false
TARGET_USES_UNCOMPRESSED_KERNEL := false

BOARD_KERNEL_CMDLINE := androidboot.console=ttyMSM0
BOARD_KERNEL_CMDLINE += androidboot.hardware=qcom
BOARD_KERNEL_CMDLINE += androidboot.memcg=1
BOARD_KERNEL_CMDLINE += androidboot.usbcontroller=a600000.dwc3
BOARD_KERNEL_CMDLINE += cgroup_disable=pressure
BOARD_KERNEL_CMDLINE += cgroup.memory=nokmem,nosocket
# No earlycon= here. lagoon.dtsi already passes
# earlycon=msm_geni_serial,0x98c000 in /chosen/bootargs, which is
# qupv3_se9_2uart - the qcom,msm-geni-console SE on the qupv3_1 wrapper, i.e.
# the actual debug UART. This line used to read 0x888000, which is
# qupv3_se2_i2c/qupv3_se2_spi: a different serial engine, on a different
# wrapper (qupv3_0), with different clocks, and status = "disabled" in DT.
# It was inert only by luck - the DTB bootargs are parsed first and
# setup_earlycon() returns -EALREADY for any later earlycon= - so the bogus
# address was never used. Had it won, earlycon would have driven MMIO at an
# unclocked, disabled QUP SE before any console existed to report it.
BOARD_KERNEL_CMDLINE += loop.max_part=7
BOARD_KERNEL_CMDLINE += lpm_levels.sleep_disabled=1
BOARD_KERNEL_CMDLINE += msm_rtb.filter=0x237
BOARD_KERNEL_CMDLINE += service_locator.enable=1
BOARD_KERNEL_CMDLINE += swiotlb=2048
BOARD_KERNEL_CMDLINE += video=vfb:640x400,bpp=32,memsize=3072000
BOARD_KERNEL_CMDLINE += deferred_probe_timeout=300

# Do NOT enable a verbose boot console here. ttyMSM0 is a blocking 115200 baud
# console: with initcall_debug/ignore_loglevel the boot log is megabytes, every
# printk stalls the CPU that emitted it for milliseconds, and the resulting
# stretch of boot is long enough to trip the timing-sensitive panics and
# subsystem-restart timeouts this platform ships with. Post-mortem logs now come
# from pstore/ramoops instead (ramoops_region in lagoon-fp4.dtsi), which costs
# nothing at runtime and survives a reset.
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
    $(KERNEL_MODULES_OUT)/audio_wcd938x.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd938x_slave.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd9xxx.ko \
    $(KERNEL_MODULES_OUT)/audio_wcd_core.ko \
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


# Product partition
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_PRODUCT := product


# System partition
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4


# System_ext partition
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_SYSTEM_EXT := system_ext


# Others
BOARD_DO_NOT_STRIP_VENDOR_MODULES := true
BOARD_USES_GENERIC_AUDIO := true


#Enable PD locater/notifier
TARGET_PD_SERVICE_ENABLED := true


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


# RPC
TARGET_NO_RPC := true


# Sensors
USE_SENSOR_MULTI_HAL := true


# SEPolicy

# Ensure clearing out policy dirs upon BoardConfig setup. This is a workaround for QCOM build system
# pulling in BoardConfig.mk twice. These lines are no-op on open source builds.
BOARD_SEPOLICY_DIRS :=
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS :=
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS :=
PRODUCT_PUBLIC_SEPOLICY_DIRS :=
PRODUCT_PRIVATE_SEPOLICY_DIRS :=

# sepolicy_vndr/SEPolicy.mk already pulls in the device/qcom/sepolicy (QSSI)
# system_ext and product dirs, so device/qcom/sepolicy/SEPolicy.mk must not be
# included as well or every policy dir is listed twice.
include device/qcom/sepolicy_vndr/SEPolicy.mk
BOARD_SEPOLICY_DIRS += \
    $(FP_PATH)/sepolicy/vendor


# Super partition
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 6438256640
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_SUPER_PARTITION_SIZE := 6442450944

BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    odm \
    product \
    system \
    system_ext \
    vendor


# Treble
# BOARD_SYSTEMSDK_VERSIONS lives in device.mk, next to the shipping API level it
# is derived from.
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


#################################################################################
# This is the End of BoardConfig.mk file.
# Now, Pickup other split Board.mk files:
#################################################################################
-include vendor/qcom/defs/board-defs/vendor/*.mk
#################################################################################

# Vendor-specific definitions
-include vendor/fairphone/fp4/BoardConfigVendor.mk

#################################################################################

# Strip the firmware partitions back out of the OTA payload. This deliberately
# runs last so that anything the vendor board-defs included above append to
# AB_OTA_PARTITIONS is filtered too. See FP4_OTA_EXCLUDED_PARTITIONS at the top
# of this file for what is being dropped and why.
AB_OTA_PARTITIONS := $(filter-out $(FP4_OTA_EXCLUDED_PARTITIONS),$(AB_OTA_PARTITIONS))
