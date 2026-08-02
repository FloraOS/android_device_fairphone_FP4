# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024-2025 FairPhone B.V.


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

# Use a newer clang than SOONG_LLVM_PREBUILTS_PATH for kernel.
# Old pinned releases get dropped from prebuilts/clang over time, so pick the
# first version that is actually present instead of hard-coding a single one.
KERNEL_LLVM_PREBUILTS_DIR := $(firstword $(wildcard \
    prebuilts/clang/host/linux-x86/clang-r487747c \
    prebuilts/clang/host/linux-x86/clang-r547379 \
    prebuilts/clang/host/linux-x86/clang-r563880 \
    prebuilts/clang/host/linux-x86/clang-r574158))
ifeq ($(KERNEL_LLVM_PREBUILTS_DIR),)
$(error No usable clang prebuilt found for the kernel build under prebuilts/clang/host/linux-x86)
endif
KERNEL_LLVM_PREBUILTS_PATH := $(KERNEL_LLVM_PREBUILTS_DIR)/bin

DTC := $(HOST_OUT_EXECUTABLES)/dtc

TEMP_TOP=$(abspath .)
TARGET_KERNEL_MAKE_ENV := DTC_EXT=$(TEMP_TOP)/$(DTC)
TARGET_KERNEL_MAKE_ENV += CONFIG_BUILD_ARM64_DT_OVERLAY=y

TARGET_KERNEL_MAKE_ENV += HOSTCC=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/clang
TARGET_KERNEL_MAKE_ENV += HOSTCXX=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/clang++
TARGET_KERNEL_MAKE_ENV += HOSTAR=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-ar
TARGET_KERNEL_MAKE_ENV += HOSTLD=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/ld.lld

TARGET_KERNEL_MAKE_ENV += CC=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/clang
TARGET_KERNEL_MAKE_ENV += LD=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/ld.lld
TARGET_KERNEL_MAKE_ENV += AR=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-ar
TARGET_KERNEL_MAKE_ENV += LLVM_AR=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-ar
TARGET_KERNEL_MAKE_ENV += NM=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-nm
TARGET_KERNEL_MAKE_ENV += LLVM_NM=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-nm
TARGET_KERNEL_MAKE_ENV += OBJCOPY=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-objcopy
TARGET_KERNEL_MAKE_ENV += OBJDUMP=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-objdump
TARGET_KERNEL_MAKE_ENV += STRIP=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-strip
TARGET_KERNEL_MAKE_ENV += READELF=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-readelf
TARGET_KERNEL_MAKE_ENV += OBJSIZE=$(TEMP_TOP)/$(KERNEL_LLVM_PREBUILTS_PATH)/llvm-size
TARGET_KERNEL_MAKE_ENV += LLVM=1 LLVM_IAS=1

TARGET_KERNEL_MAKE_ENV += BINDGEN=$(TEMP_TOP)/$(HOST_OUT_EXECUTABLES)/bindgen
TARGET_KERNEL_MAKE_ENV += CPIO=$(TEMP_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/cpio
TARGET_KERNEL_MAKE_ENV += DEPMOD=$(TEMP_TOP)/$(HOST_OUT_EXECUTABLES)/depmod
TARGET_KERNEL_MAKE_ENV += LEX=$(TEMP_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/flex
TARGET_KERNEL_MAKE_ENV += M4=$(TEMP_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/m4
TARGET_KERNEL_MAKE_ENV += YACC=$(TEMP_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/bison

# Vendor HALs put the kernel's headers_install output on the include path with
# -I, which is searched before bionic, so the raw uapi headers shadow bionic's
# scrubbed ones and redefine what bionic's public headers define themselves.
# Strip the libc-owned headers back out once they have been installed.
KERNEL_HEADERS_POST_INSTALL_TOOL := $(FP_PATH)/tools/prune_kernel_uapi_headers.py

# soong_ui hands the build a sanitised PATH in which every host tool it does not
# sanction resolves to a stub that fails. perl is one of those, and the kernel
# needs it in two places that cannot be redirected with a make variable:
# lib/Makefile's OID registry generator and kernel/gen_kheaders.sh. Give the
# kernel sub-make a PATH prefix holding just perl, taken from the host.
KERNEL_HOST_PERL := $(firstword $(wildcard /usr/bin/perl /bin/perl /usr/local/bin/perl))
ifeq ($(KERNEL_HOST_PERL),)
$(error No host perl found; building the msm-4.19 kernel requires one)
endif
KERNEL_HOST_TOOLS := $(TARGET_OUT_INTERMEDIATES)/kernel-host-tools
TARGET_KERNEL_MAKE_ENV += PATH=$(TEMP_TOP)/$(KERNEL_HOST_TOOLS):$$PATH

# Build kernel
include $(TARGET_KERNEL_SOURCE)/AndroidKernel.mk

$(KERNEL_HOST_TOOLS)/perl:
	$(hide) mkdir -p $(dir $@)
	$(hide) ln -sf $(KERNEL_HOST_PERL) $@

$(TARGET_PREBUILT_KERNEL): $(DTC) $(KERNEL_HOST_TOOLS)/perl
$(KERNEL_HEADERS_INSTALL): $(KERNEL_HOST_TOOLS)/perl

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
# tune2fs for recovery
#----------------------------------------------------------------------
# fs_mgr runs /system/bin/tune2fs to enable quota, casefolding, metadata_csum
# and fs-verity on the ext4 filesystems it checks or formats, and recovery
# hits those paths every time it wipes or reformats a partition. There is no
# tune2fs.recovery module in external/e2fsprogs - only the system binary and
# the static tune2fs_ramdisk one - so recovery has always logged
#
#   Unable to ... because /system/bin/tune2fs is missing
#
# and skipped the tuning. tune2fs_ramdisk is statically linked, so the same
# binary device.mk installs into the first-stage ramdisk can be dropped into
# the recovery root as-is. mkbootfs takes the mode from the system image's
# fs_config table, where system/bin/tune2fs is already 0755.
FP4_RAMDISK_TUNE2FS := $(TARGET_RAMDISK_OUT)/system/bin/tune2fs
FP4_RECOVERY_TUNE2FS := $(TARGET_RECOVERY_ROOT_OUT)/system/bin/tune2fs

$(FP4_RECOVERY_TUNE2FS): $(FP4_RAMDISK_TUNE2FS)
	@echo "Install: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -f $< $@
	$(hide) chmod 755 $@

ALL_DEFAULT_INSTALLED_MODULES += $(FP4_RECOVERY_TUNE2FS)


#----------------------------------------------------------------------
# Shell in the first stage ramdisk (eng only)
#----------------------------------------------------------------------
# rootdir/first_stage.sh needs an interpreter, and the first stage ramdisk only
# ships static binaries (init, e2fsck, tune2fs), so sh would have nothing to run
# under. sh is dynamically linked but its only NEEDED entry is libc.so, and the
# ramdisk already carries system/lib64/{libc,libdl,ld-android}.so - the one
# missing piece is the interpreter named in its PT_INTERP, /system/bin/linker64.
#
# Take the bootstrap linker for that. The installed /system/bin/linker64 is a
# symlink into /apex/com.android.runtime, which is not mounted this early;
# /system/bin/bootstrap/linker64 is the real binary that exists precisely for
# processes that run before the APEXes are up.
#
# Both land on paths that the system image's generated fs_config table already
# describes as 0755, so mkbootfs gives them the right mode.
ifneq (,$(filter eng,$(TARGET_BUILD_VARIANT)))
FP4_RAMDISK_SH := $(TARGET_RAMDISK_OUT)/system/bin/sh
FP4_RAMDISK_LINKER := $(TARGET_RAMDISK_OUT)/system/bin/linker64

$(FP4_RAMDISK_SH): $(TARGET_OUT)/bin/sh
	@echo "Install: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -f $< $@
	$(hide) chmod 755 $@

$(FP4_RAMDISK_LINKER): $(TARGET_OUT)/bin/bootstrap/linker64
	@echo "Install: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -f $< $@
	$(hide) chmod 755 $@

FP4_RAMDISK_TOYBOX := $(TARGET_RAMDISK_OUT)/system/bin/toybox

$(FP4_RAMDISK_TOYBOX): $(TARGET_OUT)/bin/toybox-static64
	@echo "Install: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -f $< $@
	$(hide) chmod 755 $@

ALL_DEFAULT_INSTALLED_MODULES += $(FP4_RAMDISK_SH) $(FP4_RAMDISK_LINKER) $(FP4_RAMDISK_TOYBOX)
endif


#----------------------------------------------------------------------
# extra images
#----------------------------------------------------------------------
include $(FP_PATH)/generate_extra_images.mk


#----------------------------------------------------------------------
# Compile EDK II bootloader
#----------------------------------------------------------------------
#include bootable/bootloader/edk2/AndroidBoot.mk
