# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024-2025 FairPhone B.V.

FP_PATH := device/fairphone/FP4


# Call the vendor setup
$(call inherit-product-if-exists, vendor/fairphone/fp4/device-vendor.mk)

# Inherit Virtual AB configs
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

# Inherit GSI keys to first stage ramdisk
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)

# For PRODUCT_COPY_FILES, the first instance takes precedence.
# Since we want use QC specific files, we should inherit
# device-vendor.mk first to make sure QC specific files gets installed.
$(call inherit-product-if-exists, $(QCPATH)/common/config/device-vendor.mk)

# Inherit generic AOSP content for telephony based 64-bit devices
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)


# API level the device was shipped
PRODUCT_SHIPPING_API_LEVEL := 30
SHIPPING_API_LEVEL := 30

# GRF levels
BOARD_SHIPPING_API_LEVEL := 30
BOARD_API_LEVEL := 30


PRODUCT_BRAND := Fairphone
PRODUCT_DEVICE := FP4
PRODUCT_MANUFACTURER := Fairphone
PRODUCT_MODEL := FP4
PRODUCT_NAME := FP4

# Actual product name is slightly different. Hence, use the actual name
# only in fingerprint while keeping it as FP4 everywhere else.
TARGET_PRODUCT_OVERRIDE := FP4eea
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=$(TARGET_PRODUCT_OVERRIDE) \
    TARGET_PRODUCT=$(TARGET_PRODUCT_OVERRIDE)

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

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true


# Dynamic partition
BOARD_DYNAMIC_PARTITION_ENABLE := true # Enable dynamic partitions by default
PRODUCT_USE_DYNAMIC_PARTITIONS := true


# Propagate platform SPL also to boot and vendor properties. Gets included in AVB metadata as well,
# which needs to be consistent in order for OTAs to apply.
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)


# Also, there is no need to build an OTA package as this will be done later
# when we combine this system build with the non-system images.
TARGET_SKIP_OTA_PACKAGE := true


# Atrace
PRODUCT_PACKAGES += \
    android.hardware.atrace@1.0-service


# Audio
AUDIO_FEATURE_ENABLED_DLKM := true
TARGET_USES_AOSP_FOR_AUDIO := false

AUDIO_HAL_PATH := hardware/qcom/audio

PRODUCT_PACKAGES += \
    android.hardware.audio.common@6.0 \
    android.hardware.audio.common@6.0-util \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.audio.effect@6.0 \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.audio@6.0 \
    android.hardware.audio@6.0-impl \
    android.hardware.soundtrigger@2.3-impl \
    audio.primary.lito \
    audio.r_submix.default \
    audio.usb.default \
    sound_trigger.primary.lito

PRODUCT_PACKAGES += \
    libaudio-resampler \
    libaudiohal@6.0 \
    liba2dpoffload \
    libbatterylistener \
    libcirrusspkrprot \
    libcomprcapture \
    libexthwplugin \
    libhdmiedid \
    libhfp \
    libsndmonitor \
    libspkrprot \
    libqcompostprocbundle \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    libvolumelistener

ifneq ($(QCPATH),)
PRODUCT_PACKAGES += \
    libhdmipassthru \
    libssrec
endif

#Audio DLKM
AUDIO_DLKM := audio_adsp_loader.ko
AUDIO_DLKM += audio_bolero_cdc.ko
AUDIO_DLKM += audio_hdmi.ko
AUDIO_DLKM += audio_machine_lito.ko
AUDIO_DLKM += audio_mbhc.ko
AUDIO_DLKM += audio_native.ko
AUDIO_DLKM += audio_pinctrl_lpi.ko
AUDIO_DLKM += audio_platform.ko
AUDIO_DLKM += audio_q6.ko
AUDIO_DLKM += audio_q6_notifier.ko
AUDIO_DLKM += audio_q6_pdr.ko
AUDIO_DLKM += audio_rx_macro.ko
AUDIO_DLKM += audio_snd_event.ko
AUDIO_DLKM += audio_stub.ko
AUDIO_DLKM += audio_swr.ko
AUDIO_DLKM += audio_swr_ctrl.ko
AUDIO_DLKM += audio_tx_macro.ko
AUDIO_DLKM += audio_usf.ko
AUDIO_DLKM += audio_va_macro.ko
AUDIO_DLKM += audio_wcd938x.ko
AUDIO_DLKM += audio_wcd938x_slave.ko
AUDIO_DLKM += audio_wcd9xxx.ko
AUDIO_DLKM += audio_wcd_core.ko
AUDIO_DLKM += audio_wsa_macro.ko
AUDIO_DLKM += audio_apr.ko

PRODUCT_PACKAGES += $(AUDIO_DLKM)

PRODUCT_COPY_FILES += \
    $(AUDIO_HAL_PATH)/configs/lito/audio_effects.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.conf \
    $(AUDIO_HAL_PATH)/configs/lito/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(AUDIO_HAL_PATH)/configs/lito/audio_io_policy.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_io_policy.conf \
    $(AUDIO_HAL_PATH)/configs/lito/audio_platform_info.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_info.xml \
    $(AUDIO_HAL_PATH)/configs/lito/audio_platform_info_intcodec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_info_intcodec.xml \
    $(AUDIO_HAL_PATH)/configs/lito/audio_platform_info_lagoon_qrd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_info_lagoon_qrd.xml \
    $(AUDIO_HAL_PATH)/configs/lito/audio_platform_info_qrd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_info_qrd.xml \
    $(AUDIO_HAL_PATH)/configs/lito/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml \
    $(AUDIO_HAL_PATH)/configs/lito/mixer_paths_cdp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths_cdp.xml \
    $(AUDIO_HAL_PATH)/configs/lito/mixer_paths_lagoonmtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths_lagoonmtp.xml \
    $(AUDIO_HAL_PATH)/configs/lito/mixer_paths_lagoonqrd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths_lagoonqrd.xml \
    $(AUDIO_HAL_PATH)/configs/lito/mixer_paths_orchidmtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths_orchidmtp.xml \
    $(AUDIO_HAL_PATH)/configs/lito/mixer_paths_qrd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths_qrd.xml \
    $(AUDIO_HAL_PATH)/configs/lito/sound_trigger_mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_mixer_paths.xml \
    $(AUDIO_HAL_PATH)/configs/lito/sound_trigger_mixer_paths_cdp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_mixer_paths_cdp.xml \
    $(AUDIO_HAL_PATH)/configs/lito/sound_trigger_mixer_paths_lagoonmtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_mixer_paths_lagoonmtp.xml \
    $(AUDIO_HAL_PATH)/configs/lito/sound_trigger_mixer_paths_lagoonqrd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_mixer_paths_lagoonqrd.xml \
    $(AUDIO_HAL_PATH)/configs/lito/sound_trigger_mixer_paths_orchidmtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_mixer_paths_orchidmtp.xml \
    $(AUDIO_HAL_PATH)/configs/lito/sound_trigger_mixer_paths_qrd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_mixer_paths_qrd.xml \
    $(AUDIO_HAL_PATH)/configs/lito/sound_trigger_platform_info.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_platform_info.xml

# Custom audio configs
PRODUCT_COPY_FILES += \
    $(FP_PATH)/audio/audio_platform_info_lagoon_fp4.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_info_lagoon_fp4.xml \
    $(FP_PATH)/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(FP_PATH)/audio/bluetooth_hearing_aid_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_hearing_aid_audio_policy_configuration.xml \
    $(FP_PATH)/audio/bluetooth_hearing_aid_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_hearing_aid_audio_policy_configuration.xml \
    $(FP_PATH)/audio/mixer_paths_lagoon_fp4.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths_lagoon_fp4.xml

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
    $(AUDIO_HAL_PATH)/configs/common/bluetooth_qti_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_qti_audio_policy_configuration.xml

# Audio Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml

include $(FP_PATH)/audio_properties.mk


# ANT
PRODUCT_PACKAGES += \
    com.dsi.ant@1.0 \
    com.dsi.ant@1.0.vendor

# Bluetooth
PRODUCT_PACKAGES += \
    audio.bluetooth.default \
    android.hardware.bluetooth.audio@2.0-impl \
    android.hardware.bluetooth@1.0 \
    bt_stack.conf \
    libbluetooth_audio_session \
    libchrome \
    libchrome.vendor \
    vendor.qti.hardware.bluetooth_audio@2.0 \
    vendor.qti.hardware.bluetooth_audio@2.1.vendor

# Bluetooth Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.fflag.override.settings_bluetooth_hearing_aid=true \
    persist.vendor.qcom.bluetooth.a2dp_offload_cap=sbc-aptx-aptxtws-aptxhd-aac-ldac-aptxadaptiver2 \
    persist.vendor.qcom.bluetooth.aac_vbr_ctl.enabled=true \
    persist.vendor.qcom.bluetooth.aptxadaptiver2_1_support=false \
    persist.vendor.qcom.bluetooth.enable.splita2dp=true \
    persist.vendor.qcom.bluetooth.scram.enabled=true \
    persist.vendor.qcom.bluetooth.soc=cherokee \
    persist.vendor.qcom.bluetooth.twsp_state.enabled=false \
    persist.vendor.service.bdroid.soc.alwayson=true \
    ro.vendor.bluetooth.wipower=false


# Board platforms lists to be used for
# TARGET_BOARD_PLATFORM specific featurization
QCOM_BOARD_PLATFORMS += lito


# Boot
PRODUCT_PACKAGES += \
    android.hardware.boot@1.1-impl-qti \
    android.hardware.boot@1.1-impl-qti.recovery \
    android.hardware.boot@1.1-service \
    bootctrl.lito \
    libminui

# Shorten wait time for shutdown
PRODUCT_PROPERTY_OVERRIDES += \
    sys.vendor.shutdown.waittime=500


# Skip boot jars check
SKIP_BOOT_JARS_CHECK := true


# Camera
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-external \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-legacy \
    android.hardware.camera.provider@2.4-service_64 \
    camera.device@3.5-impl \
    camera.device@3.6-external-impl \
    libcamera2ndk_vendor \
    libexif.vendor \
    vendor.qti.hardware.camera.device@1.0 \
    vendor.qti.hardware.camera.postproc@1.0 \
    vendor.qti.hardware.camera.postproc@1.0.vendor

# Feature flags for camera
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml


# Compile SystemUI on device with `speed`.
PRODUCT_PROPERTY_OVERRIDES = \
    dalvik.vm.systemuicompilerfilter=speed


# Dalvik/Heap
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)


# Use 64-bit dex2oat for better dexopt time.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.dex2oat64.enabled=true


# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@3.0-impl-qti-display \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    gralloc.default \
    gralloc.lito \
    libdisplayconfig.qti \
    libdisplayconfig.qti.vendor \
    libdrm \
    libgralloc.qti \
    libgui_vendor \
    libqdMetaData \
    libqdutils \
    libsdmutils \
    lights.lito \
    memtrack.lito \
    modetest \
    vendor.display.config@1.14 \
    vendor.qti.hardware.display.allocator-service

PRODUCT_PACKAGES += \
    init.qti.display_boot.sh

# From hardware/qcom/display/config/display-product.mk
include $(FP_PATH)/display-product.mk

ifneq ($(QCPATH),)
PRODUCT_PACKAGES += \
    libsdmcore \
    vendor.qti.hardware.display.composer-service

# Pixelworks
PXLW_IRIS_SERVICE_PASSTHROUGH := 1
IRIS_BSP_PLATFORM := QCOM_DRM
IRIS_CFLAGS := -DPXLW_IRIS

PRODUCT_PACKAGES += \
    irisConfig \
    irisdbgc \
    irisdbgd \
    libpwirisIoctlWrapper \
    libpwirisfeature \
    libpwirishalwrapper \
    libpwirisservice \
    vendor.pixelworks.hardware.display.iris-service \
    vendor.pixelworks.hardware.feature.irisfeature-service

else
# Following are dependencies for libsdmcore and
# vendor.qti.hardware.display.composer-service
PRODUCT_PACKAGES += \
    libdrm.vendor \
    libdrmutils \
    libgpu_tonemapper \
    libhistogram \
    libsdedrm \
    vendor.qti.hardware.display.composer@3.0.vendor
endif

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.sf.color_mode=0


# Display Properties
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi


# DPM
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.dpmhalservice.enable=1


# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.3-service.clearkey


# Encryption
PRODUCT_PROPERTY_OVERRIDES += \
    ro.crypto.volume.filenames_mode = "aes-256-cts"


# Fastbootd
PRODUCT_PACKAGES += fastbootd
# Add default implementation of fastboot HAL.
PRODUCT_PACKAGES += android.hardware.fastboot@1.0-impl-mock


# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.1-service

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml


# Feature flags and Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2020-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml


# framework detect libs
PRODUCT_PACKAGES += \
    libqti_vndfwk_detect.vendor \
    libvndfwk_detect_jni.qti.vendor \
    vndservicemanager


# FRP
PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/bootdevice/by-name/frp


# fs Config
PRODUCT_PACKAGES += fs_config_files


# Fstman
PRODUCT_PACKAGES += \
    vendor.qti.hardware.fstman@1.0.vendor


# GPS
LOC_HIDL_VERSION = 4.3

PRODUCT_PACKAGES += \
    android.hardware.gnss@2.1-impl-qti \
    android.hardware.gnss@2.1-service-qti \
    flp.conf \
    gnss_antenna_info.conf \
    gps.conf \
    libbatching \
    libgeofencing \
    libgnss \
    libgps.utils \
    libloc_core \
    liblocation_api

PRODUCT_PACKAGES += \
    gnss@2.0-base.policy \
    gnss@2.0-xtra-daemon.policy \
    gnss@2.0-xtwifi-client.policy

ifneq ($(QCPATH),)
PRODUCT_PACKAGES += \
    libgnsspps \
    libloc_api_v02 \
    libsynergy_loc_api
endif

# gps/location secuity configuration file
PRODUCT_COPY_FILES += \
    $(FP_PATH)/configs/sec_config:$(TARGET_COPY_OUT_VENDOR)/etc/sec_config

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

PRODUCT_PROPERTY_OVERRIDES += \
    persist.backup.ntpServer=0.pool.ntp.org


# Graphics
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.vulkan=adreno \
    ro.hardware.egl=adreno \
    ro.gfx.driver.1=com.qualcomm.qti.gpudrivers.lito.api30


# GZip
PRODUCT_HOST_PACKAGES += \
    minigzip


# Healthd packages
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl-qti \
    android.hardware.health@2.1-service \
    libhealthd.msm


# HIDL
PRODUCT_PACKAGES += \
    libhidltransport.vendor \
    libhwbinder.vendor


# Enable incremental FS feature
PRODUCT_PROPERTY_OVERRIDES += ro.incremental.enable=1


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


# IPACM
PRODUCT_PACKAGES += \
    ipacm \
    IPACM_cfg.xml \
    libipanat \
    liboffloadhal \
    libqsap_sdk


# Json
PRODUCT_PACKAGES += \
    libjson


# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/FP4/$(KERNEL_MODULES_INSTALL)/lib/modules


# Libion
PRODUCT_PACKAGES += \
    libion


# Librmnetctrl
PRODUCT_PACKAGES += \
    librmnetctl


# Libpsi
PRODUCT_PACKAGES += \
    libpsi.vendor


# Libxml2
PRODUCT_PACKAGES += \
    libxml2.vendor


# Lights
PRODUCT_PACKAGES += \
    android.hardware.lights-service.qti


# Logwrapper
PRODUCT_PACKAGES += \
    liblogwrap


# Manufacturer
PRODUCT_PROPERTY_OVERRIDES += \
    ro.soc.manufacturer=QTI


# Media
MSM_VIDC_TARGET_LIST := lito
MASTER_SIDE_CP_TARGET_LIST := lito

# Enable CLANG/LLVM integer-overflow sanitization
TARGET_ENABLE_VIDC_INTSAN := true

# Enable DIAG mode for CLANG/LLVM integer-overflow sanitization
# TARGET_ENABLE_VIDC_INTSAN must be set to 'true' before enabling DIAG mode
# NOTE: DIAG mode should be used only for debug builds
TARGET_ENABLE_VIDC_INTSAN_DIAG := false

PRODUCT_PACKAGES += \
    init.qti.media.sh \
    libavservices_minijail \
    libavservices_minijail.vendor \
    libcodec2_hidl@1.0.vendor \
    libcodec2_vndk.vendor \
    libc2dcolorconvert \
    libOmxG711Enc \
    libOmxAacEnc \
    libOmxAmrEnc \
    libOmxCore \
    libOmxEvrcEnc \
    libOmxQcelp13Enc \
    libOmxVdec \
    libOmxVenc \
    libmediaplayerservice \
    libmm-omxcore \
    libnbaio \
    libstagefrighthw \
    libstagefright_httplive \
    libstagefright_softomx.vendor

ifneq ($(QCPATH),)
PRODUCT_PACKAGES += \
    libOmxSwVdec \
    libOmxSwVencMpeg4
endif

#Vendor property to enable Codec2 for audio and OMX for Video
PRODUCT_PROPERTY_OVERRIDES += debug.stagefright.ccodec=1

#
# media profiles and media codecs xmls for regular system
#
PRODUCT_COPY_FILES += \
    $(FP_PATH)/media/media_codecs_performance_lagoon_v1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance_v3.xml \
    $(FP_PATH)/media/media_codecs_vendor.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_vendor.xml \
    $(FP_PATH)/media/media_codecs_vendor_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_vendor_audio.xml \
    $(FP_PATH)/media/media_codecs_vendor_lagoon_v1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_vendor_v3.xml \
    $(FP_PATH)/media/media_profiles_vendor.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_vendor.xml

# media files for GSI - using default paths
PRODUCT_COPY_FILES += \
    $(FP_PATH)/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(FP_PATH)/media/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(FP_PATH)/media/media_profiles.xml:$(TARGET_COPY_OUT_ODM)/etc/media_profiles_V1_0.xml

# other media config
PRODUCT_COPY_FILES += \
    $(FP_PATH)/media/mediacodec-seccomp.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy \
    $(FP_PATH)/media/system_properties.xml:$(TARGET_COPY_OUT_VENDOR)/etc/system_properties.xml

PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video_le.xml

PRODUCT_PROPERTY_OVERRIDES += \
    debug.stagefright.omx_default_rank=0 \
    media.settings.xml=/vendor/etc/media_profiles_vendor.xml

# Media Performance Class 11
PRODUCT_PROPERTY_OVERRIDES += \
    ro.odm.build.media_performance_class=30

PRODUCT_PACKAGES += \
    libcodec2_vndk.vendor \
    libcodec2_hidl@1.0.vendor


# Metadata encryption
PRODUCT_PROPERTY_OVERRIDES += \
    ro.crypto.dm_default_key.options_format.version = 2 \
    ro.crypto.volume.metadata.method=dm-default-key


# MSM updater library
PRODUCT_PACKAGES += \
    librecovery_updater_msm


# NFC (ST stack)
$(call inherit-product, vendor/st/nfc/st21nfc/NfcDeviceConfigVendor.st21nfc.mk)

# rc file
PRODUCT_PACKAGES += \
    init.stnfc.rc

# NFC Config files
PRODUCT_COPY_FILES += \
    $(FP_PATH)/nfc/libnfc-hal-st.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-hal-st.conf:st \
    $(FP_PATH)/nfc/libnfc-nci.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-nci.conf:st \
    $(FP_PATH)/nfc/st21nfc_conf.txt:$(TARGET_COPY_OUT_VENDOR)/etc/st21nfc_conf.txt

PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.st_nfc_defaut_se=SIM1 \
    ro.hardware.nfc_nci=pn54x


# Oemaids
PRODUCT_PACKAGES += \
    liboemaids_vendor


# OEM Unlock reporting
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.oem_unlock_supported=1


#
# system prop for opengles version
#
# 196608 is decimal for 0x30000 to report version 3
# 196609 is decimal for 0x30001 to report version 3.1
# 196610 is decimal for 0x30002 to report version 3.2
PRODUCT_PROPERTY_OVERRIDES  += \
    ro.opengles.version=196610


# Perf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=libqti-perfd-client.so \
    ro.vendor.perf-hal.ver=2.2


# We don't have the calibration data as this sort of
# data can only be generated at the factory so don't generate persist.img
TARGET_SKIP_PERSIST_IMG := true


# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/power/config/lito/powerhint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.xml

# Pasr manager
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.power.pasr.enabled=true \
    vendor.pasr.activemode.enabled=true


# privapp-permissions whitelisting (To Fix CTS :privappPermissionsMustBeEnforced)
PRODUCT_PROPERTY_OVERRIDES += ro.control_privapp_permissions=enforce


# Protobuf
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full \
    libprotobuf-cpp-full-vendorcompat \
    libprotobuf-cpp-lite-vendorcompat


# include additional QCOM build utilities
include $(FP_PATH)/utils.mk


# QCOM Sysd
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.qcomsysd.enabled=1


# target specific runtime prop for qspm
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.qspm.enable=true


# Radio
PRODUCT_PACKAGES += \
    android.hardware.radio.config@1.0 \
    android.hardware.radio.deprecated@1.0 \
    android.hardware.radio@1.4


# Sensors
PRODUCT_PACKAGES += \
    sensors.FP4 \
    android.hardware.sensors@2.0-service.multihal \
    android.hardware.sensors@2.0-ScopedWakelock.vendor \
    libsensorndkbridge

# Sensor conf files
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml

PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.sensors.debug.ssc_qmi_debug=true \
    persist.vendor.sensors.allow_non_default_discovery=true


# Service tracker
PRODUCT_PACKAGES += \
    vendor.qti.hardware.servicetracker@1.2.vendor


# SDCard
# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard


# tcmiface for tcm support
PRODUCT_PACKAGES += \
    tcmiface

PRODUCT_BOOT_JARS += \
    tcmiface


# Telephony Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml

# Enable Dual SIM by default
PRODUCT_PROPERTY_OVERRIDES += persist.radio.multisim.config=dsds

# Vendor property to enable advanced network scanning
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.enableadvancedscan=true

# Other radio/RIL properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.telephony.iwlan_operation_mode=AP-assisted \
    persist.vendor.radio.apm_sim_not_pwdn=1 \
    persist.vendor.radio.sib16_support=1 \
    persist.vendor.radio.custom_ecc=1 \
    vendor.rild.libpath=/vendor/lib64/libril-qc-hal-qmi.so \
    persist.vendor.radio.procedure_bytes=SKIP \
    persist.vendor.radio.rat_on=combine


# Tinyxml
PRODUCT_PACKAGES += \
    libtinyxml


# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal@2.0 \
    android.hardware.thermal@2.0-service.qti


# Treble
PRODUCT_VENDOR_MOVE_ENABLED := true
TARGET_MOUNT_POINTS_SYMLINKS := false


# USB
PRODUCT_PROPERTY_OVERRIDES += vendor.usb.diag.func.name=diag
PRODUCT_PROPERTY_OVERRIDES += vendor.usb.use_ffs_mtp=0

PRODUCT_PACKAGES += \
    android.hardware.usb@1.2-service-qti

# Use prebuilt metadata.img from radio files instead of building
# from source.
BOARD_USE_PREBUILT_METADATAIMAGE := true

# Userdata
# Prebuilt userdata image triggers storage formatting on boot.
# Required to adjust for different storage sizes of FP4 models.
BOARD_PREBUILT_USERDATAIMAGE := $(FP_PATH)/userdata.img


# Userdata checkpoint
PRODUCT_PACKAGES += \
    checkpoint_gc


# Verity
PRODUCT_SUPPORTS_VERITY := false


# Vibrator
PRODUCT_PACKAGES += vendor.qti.hardware.vibrator.service

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/vibrator/excluded-input-devices.xml:$(TARGET_COPY_OUT_VENDOR)/etc/excluded-input-devices.xml


# Wifi
# WLAN driver config
PRODUCT_COPY_FILES += \
    $(FP_PATH)/wifi/WCNSS_qcom_cfg.ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/WCNSS_qcom_cfg.ini

# WLAN specific aosp flag
TARGET_USES_AOSP_FOR_WLAN := false

# Enable STA + SAP Concurrency.
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# Enable SAP + SAP Feature.
QC_WIFI_HIDL_FEATURE_DUAL_AP := true

# Enable vendor properties
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.aware.interface=wifi-aware0

WLAN_CHIPSET := qca_cld3

# WiFi HAL
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service

# WiFi Drivers
PRODUCT_PACKAGES += \
    $(WLAN_CHIPSET)_wlan.ko

# WiFi Components
PRODUCT_PACKAGES += \
    e_loop \
    hostapd \
    hostapd.accept \
    hostapd.deny \
    hostapd_cli \
    hostapd_default.conf \
    icm.conf \
    libnl \
    libqsap_sdk \
    libwifi-hal-qcom \
    libwfdaac_vendor \
    libwpa_client \
    p2p_supplicant_overlay.conf \
    sigma_dut \
    vendor.qti.hardware.wifi.supplicant@1.0.vendor \
    wificond \
    wpa_cli \
    wpa_supplicant.conf \
    wpa_supplicant \
    wpa_supplicant_overlay.conf

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml


# Updater for sideload in recovery
PRODUCT_PACKAGES += \
    update_engine_sideload


# Enable zygote critical window.
PRODUCT_PROPERTY_OVERRIDES += \
    zygote.critical_window.minute=10


#soong namespace for qssi vs vendor differentiation
SOONG_CONFIG_NAMESPACES += qssi_vs_vendor
SOONG_CONFIG_qssi_vs_vendor += qssi_or_vendor
SOONG_CONFIG_qssi_vs_vendor_qssi_or_vendor := vendor

# display
SOONG_CONFIG_NAMESPACES += qtidisplaycommonsys
SOONG_CONFIG_qtidisplaycommonsys := displayconfig_enabled
SOONG_CONFIG_qtidisplaycommonsys_displayconfig_enabled := true

# lights
SOONG_CONFIG_NAMESPACES += lights
SOONG_CONFIG_lights += lighttargets
ifeq ($(PLATFORM_VERSION), 11)
SOONG_CONFIG_lights_lighttargets := lightaidltarget
else
SOONG_CONFIG_lights_lighttargets := lightaidlV1target
endif


# Inherit the proprietary setup
$(call inherit-product, device/fairphone/fp4-proprietary/device-vendor.mk)


# Build some more display components to vendor
$(call inherit-product, vendor/qcom/opensource/commonsys-intf/display/config/display-interfaces-product.mk)
###################################################################################
