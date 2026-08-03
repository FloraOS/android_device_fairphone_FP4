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


# AVB signing key.
#
# This is the key the bootloader pins when it is locked, so a release build must
# NOT use the AOSP test key: external/avb/test/data/testkey_rsa4096.pem is public
# and anyone can sign an image with it, which makes verified boot decorative.
#
# Point FLORAOS_AVB_KEY at the real 4096-bit RSA key to sign for real, e.g.
#
#     make FLORAOS_AVB_KEY=vendor/f104a-keys/avb/floraos_rsa4096.pem ...
#
# and put the matching public key in the bootloader with
# `fastboot flash avb_custom_key` before locking. Verify what actually got used
# with `avbtool info_image --image vbmeta.img` - the "Public key (sha1)" of the
# AOSP test key is 2597c218aae470a130f61162feaae70afd97f011.
# These are consumed by kati, not soong, so unlike an apex_key or an
# android_app_certificate they may be absolute paths outside the tree - which is
# how the release keys stay out of the source tree entirely:
#
#     m dist FLORAOS_AVB_KEY=$KEYDIR/avb/floraos_vbmeta_rsa4096.pem \
#            FLORAOS_AVB_SYSTEM_KEY=$KEYDIR/avb/floraos_vbmeta_system_rsa4096.pem
#
# The two levels are deliberately separate variables. Signing both with one key
# throws away the reason the chain exists: a system-only OTA should be able to
# re-sign vbmeta_system without touching the key the bootloader pins.
FLORAOS_AVB_KEY ?= external/avb/test/data/testkey_rsa4096.pem
FLORAOS_AVB_SYSTEM_KEY ?= $(FLORAOS_AVB_KEY)

# Top level vbmeta: the one the bootloader verifies directly. It carries the
# hash descriptors for boot, dtbo and recovery, the hashtree descriptors for odm
# and vendor, and the chain descriptor for vbmeta_system. Without these two
# being set explicitly the build signs it with the AOSP test key by default,
# silently.
BOARD_AVB_KEY_PATH := $(FLORAOS_AVB_KEY)
BOARD_AVB_ALGORITHM := SHA256_RSA4096
BOARD_AVB_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)

# Chain partition for the system-side images. All three live in the same chained
# vbmeta_system descriptor so a system-only OTA can re-sign them without
# touching the top level vbmeta that the bootloader verifies.
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := $(FLORAOS_AVB_SYSTEM_KEY)
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


# DTBO partition. 0x1800000 is what the bootloader reports for dtbo_a/dtbo_b
# (fastboot getvar partition-size:dtbo_a); this used to read 0x0800000, which
# only ever under-padded the image rather than overflowing it, so the short
# write was harmless - the DTBO header bounds what the bootloader reads back.
BOARD_DTBOIMG_PARTITION_SIZE := 0x1800000


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
# No video=vfb: here. vfb is the virtual (memory backed) framebuffer driver,
# and CONFIG_FB_VIRTUAL is not set in fp4_defconfig, so the argument only ever
# got parsed and dropped. The panel comes up through the MSM DRM driver, which
# takes its mode from the DSI panel node in DT and ignores video=.
BOARD_KERNEL_CMDLINE += deferred_probe_timeout=300

# Do NOT enable a verbose boot console here. ttyMSM0 is a blocking 115200 baud
# console: with initcall_debug/ignore_loglevel the boot log is megabytes, every
# printk stalls the CPU that emitted it for milliseconds, and the resulting
# stretch of boot is long enough to trip the timing-sensitive panics and
# subsystem-restart timeouts this platform ships with. Post-mortem logs now come
# from pstore/ramoops instead (ramoops_region in lagoon-fp4.dtsi), which costs
# nothing at runtime and survives a reset.
ifneq (,$(filter eng,$(TARGET_BUILD_VARIANT)))
# Put the kernel console on the panel, not on the UART.
#
# This device has no reachable log of its own. pstore/ramoops attaches but the
# region does not survive a reset (a marker written to /dev/pmsg0 is gone even
# after a warm key-combo reboot), /data never gets far enough to hold a
# tombstone, and the debug UART needs the phone opened. fp4_defconfig now
# carries CONFIG_VT, CONFIG_FRAMEBUFFER_CONSOLE and CONFIG_DRM_FBDEV_EMULATION,
# so msm_drv.c's msm_fbdev_init() gives us an fbdev on the DSI panel and fbcon
# binds a console to it. printk then lands on the screen, where it can simply be
# photographed. The VT screen buffer survives the dummycon-to-fbcon handover, so
# the last screenful from before the panel came up is redrawn too.
#
# This also settles the console cost. Dropping console=ttyMSM0 from this list on
# its own changed nothing, because register_console() auto-enables the first
# console that registers whenever no console= was given on the command line (see
# the has_preferred logic in kernel/printk/printk.c), and the geni driver
# registers one - "console [ttyMSM0] enabled" at 4.7s, with recovery's
# ro.boottime.init unmoved at 11.89s. Naming a console here sets
# preferred_console, which suppresses that auto-enable, so ttyMSM0 stops
# draining every printk at 11520 bytes/s and fbcon takes over at memory speed.
BOARD_KERNEL_CMDLINE += console=tty0
#
# printk to a serial console is synchronous: the CPU that called printk holds
# the console lock and busy-waits for the UART FIFO to drain at the configured
# baud rate. 115200 8N1 is 11520 bytes/s, and the cost is paid by whatever is
# booting, not in the background. Recovery makes the arithmetic plain: its
# console is enabled at 4.68s ("console [ttyMSM0] enabled"), its kmsg is ~124 kB,
# 124 kB / 11520 B/s is ~10.8s, and second stage init starts at 11.86s of which
# only 0.14s is first stage and 0.30s is the policy load. Essentially the whole
# of recovery's boot time is the UART.
#
# Recovery survives that because it only ever emits ~124 kB. A full eng boot -
# permissive, every init command logged, the vendor DLKMs, the subsystem bringup
# - emits several MB, which at the same rate is minutes of stalled CPU, long
# enough for the QCOM subsystem-restart timeouts and the apps watchdog to fire.
# That is what the device was doing: no adb, splash still on screen, then the
# watchdog dropping the SoC into EDL about six minutes in.
#
# Nothing can read this UART without opening the phone anyway. The log stays in
# the kmsg ring buffer either way, so nothing is lost by not draining it out a
# serial port at 11.5 kB/s.
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
# Land in recovery, not in the bootloader, when init hits a fatal error.
# reboot_utils.cpp defaults init_fatal_reboot_target to "bootloader", which on
# this device means fastboot with no shell and no log. Recovery gives adb back
# straight away, and it is also the only way to tell an init abort apart from a
# stall: a stall still ends in the watchdog dropping the SoC into EDL, which
# takes minutes and needs a battery pull to get out of.
BOARD_KERNEL_CMDLINE += androidboot.init_fatal_reboot_target=recovery
#
# The raw boot logger, on by default on eng (FP4_BOOT_LOGGER ?= true).
#
# This device has no post-mortem log of any kind - pstore/ramoops does not
# survive a reset, the debug UART is not reachable without opening the phone,
# and fbcon only takes the panel long after the interesting part of boot - so
# the only channel that works is writing straight at a raw partition and
# reading it back from recovery with dd. It writes at rawdump, which is 8.2 GiB
# of scratch only QCOM's crash handler ever touches, so it costs nothing and
# leaves /data alone. See rootdir/first_stage.sh for the ring layout.
#
# FP4_BOOT_LOGGER itself is defined in device.mk - product config is evaluated
# before board config, so it has to be set there to be visible to both.
# No androidboot.first_stage_console here, and there must not be one. There is
# no console for it to attach to: the debug UART needs the phone opened, and
# fbcon only takes the panel at ~4.1s, well after first stage init runs at
# ~3.9s. StartConsole() sets SA_NOCLDWAIT and then wait()s until pid 1 has no
# children left, so with nothing on /dev/console init parks in the hook before
# DoFirstStageMount() and never returns - a total hang, no adb, no USB, in
# normal boot and in recovery alike, recoverable only by forcing the device
# back to fastboot by hand. First stage logging goes to the rawdump ring
# instead (/dev/fp4_log, see rootdir/first_stage.sh).

else

# Turn the kernel console off on everything that is not eng.
#
# ActivityManagerService.isUartEnabled() greps /proc/cmdline for the literal
# "console=null" and, not finding it, posts an ongoing "Serial console enabled -
# Performance is impacted" notification that cannot be dismissed. Our cmdline
# carries androidboot.console=ttyMSM0 unconditionally, which is not the same
# token, so without this a user build ships with that notification permanently
# in the shade.
#
# It is also the right thing on its own merits: on a locked, verified-boot
# device there is no reason to keep a kernel console on the debug UART, and
# printk to it is synchronous, so every message stalls the CPU that emitted it.
BOARD_KERNEL_CMDLINE += console=null

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
        FP4_DEBUG_KERNEL_MODULES := \
            $(KERNEL_MODULES_OUT)/atomic64_test.ko \
            $(KERNEL_MODULES_OUT)/lkdtm.ko \
            $(KERNEL_MODULES_OUT)/locktorture.ko \
            $(KERNEL_MODULES_OUT)/rcutorture.ko \
            $(KERNEL_MODULES_OUT)/test_user_copy.ko \
            $(KERNEL_MODULES_OUT)/torture.ko
        BOARD_VENDOR_KERNEL_MODULES += $(FP4_DEBUG_KERNEL_MODULES)
    endif
endif

# Data
BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/rmnet_shs.ko
BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/rmnet_perf.ko

# Wifi
BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/qca_cld3_wlan.ko

# Ship the debug modules, but keep them out of modules.load.
#
# When BOARD_VENDOR_KERNEL_MODULES_LOAD is unset the build lists every entry of
# BOARD_VENDOR_KERNEL_MODULES in /vendor/lib/modules/modules.load, and that list
# is the autoload list. rcutorture and locktorture are not tests you run and
# collect: loading them spawns kthreads that hammer RCU and the locking
# primitives on every CPU for as long as they stay loaded, and lkdtm exists
# purely to crash the kernel on demand. Nothing walks this file on FP4 today
# (init.target.rc modprobes an explicit list, and there is no vendor_ramdisk),
# but anything that ever does - a modprobe --all=, a first-stage module list -
# would take the boot down with it. Keep them installed so they can still be
# insmod'ed by hand.
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(filter-out $(FP4_DEBUG_KERNEL_MODULES),$(BOARD_VENDOR_KERNEL_MODULES))


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
# OpenEUICC's own domain lives here rather than in system/sepolicy, so an AOSP
# resync never conflicts with it. See sepolicy/system_ext/private/openeuicc_app.te.
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS := $(FP_PATH)/sepolicy/system_ext/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS := $(FP_PATH)/sepolicy/system_ext/private
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
