# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 FairPhone B.V.


LOCAL_PATH := $(call my-dir)

#----------------------------------------------------------------------
# Compile Linux Kernel
#----------------------------------------------------------------------
ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
ifeq ($(KERNEL_DEFCONFIG),)
    KERNEL_DEFCONFIG := vendor/fp4_defconfig
endif
else
ifeq ($(KERNEL_DEFCONFIG),)
    KERNEL_DEFCONFIG := vendor/fp4-perf_defconfig
endif
endif

DTC := $(HOST_OUT_EXECUTABLES)/dtc

TEMP_TOP=$(abspath .)
TARGET_KERNEL_MAKE_ENV := DTC_EXT=$(TEMP_TOP)/$(DTC)
TARGET_KERNEL_MAKE_ENV += CONFIG_BUILD_ARM64_DT_OVERLAY=y

TARGET_KERNEL_MAKE_ENV += HOSTCC=$(TEMP_TOP)/$(SOONG_LLVM_PREBUILTS_PATH)/clang
TARGET_KERNEL_MAKE_ENV += HOSTCXX=$(TEMP_TOP)/$(SOONG_LLVM_PREBUILTS_PATH)/clang
TARGET_KERNEL_MAKE_ENV += HOSTAR=$(TEMP_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-ar
TARGET_KERNEL_MAKE_ENV += HOSTLD=$(TEMP_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-ld
TARGET_KERNEL_MAKE_ENV += HOSTCFLAGS="-I/usr/include -I/usr/include/x86_64-linux-gnu -L/usr/lib -L/usr/lib/x86_64-linux-gnu -fuse-ld=lld"
TARGET_KERNEL_MAKE_ENV += HOSTLDFLAGS="-L/usr/lib -L/usr/lib/x86_64-linux-gnu -fuse-ld=lld"

TARGET_KERNEL_MAKE_ENV += CC=$(TEMP_TOP)/$(SOONG_LLVM_PREBUILTS_PATH)/clang
TARGET_KERNEL_MAKE_ENV += BINDGEN=$(TEMP_TOP)/$(HOST_OUT_EXECUTABLES)/bindgen
TARGET_KERNEL_MAKE_ENV += CPIO=$(TEMP_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/cpio
TARGET_KERNEL_MAKE_ENV += DEPMOD=$(TEMP_TOP)/$(HOST_OUT_EXECUTABLES)/depmod
TARGET_KERNEL_MAKE_ENV += LEX=$(TEMP_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/flex
TARGET_KERNEL_MAKE_ENV += M4=$(TEMP_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/m4
TARGET_KERNEL_MAKE_ENV += YACC=$(TEMP_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/bison


# Build kernel
include $(TARGET_KERNEL_SOURCE)/AndroidKernel.mk

$(TARGET_PREBUILT_KERNEL): $(DTC)

$(INSTALLED_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	$(transform-prebuilt-to-target)


#----------------------------------------------------------------------
# override default make with prebuilt make path (if any)
#----------------------------------------------------------------------
ifneq (, $(wildcard $(abspath .)/prebuilts/build-tools/linux-x86/bin/make))
    MAKE := $(abspath .)/prebuilts/build-tools/linux-x86/bin/$(MAKE)
endif

#----------------------------------------------------------------------
# Configs common to AndroidBoard.mk for all targets
#----------------------------------------------------------------------
include vendor/qcom/opensource/core-utils/build/AndroidBoardCommon.mk


#----------------------------------------------------------------------
# extra images
#----------------------------------------------------------------------
include $(FP_PATH)/generate_extra_images.mk
