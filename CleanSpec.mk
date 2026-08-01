# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 FairPhone B.V.

# If you don't need to do a full clean build but would like to touch
# a file or delete some intermediate files, add a clean step to the end
# of the list.  These steps will only be run once, if they haven't been
# run before.
#
# E.g.:
#     $(call add-clean-step, touch -c external/sqlite/sqlite3.h)
#     $(call add-clean-step, rm -rf $(PRODUCT_OUT)/obj/STATIC_LIBRARIES/libz_intermediates)
#
# Always use "touch -c" and "rm -f" or "rm -rf" to gracefully deal with
# files that are missing or have been moved.
#
# Use $(PRODUCT_OUT) to get to the "out/target/product/blah/" directory.
# Use $(OUT_DIR) to refer to the "out" directory.
#
# ************************************************
# NEWER CLEAN STEPS MUST BE AT THE END OF THE LIST
# ************************************************

# $(PRODUCT_OUT)/root is the root of the system image, and it is staged by a
# LOCAL_POST_INSTALL_CMD in system/core/rootdir/create_root_structure.mk rather
# than by ninja rules. That script decides per partition whether a top level
# entry is a mount point ("mkdir -p .../root/product") or a compatibility
# symlink into /system ("ln -sf /system/product .../root/product"), and the
# commands are chained with ";" so a failure is silently ignored.
#
# Before BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE / BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE
# were set for this device, that script staged the symlink form. Once they were
# set it switched to "mkdir -p", which fails with EEXIST on the leftover
# symlink, so the stale symlinks survived into system.img. The result is a
# resolution loop, because system.img also ships the reverse compatibility
# links: /product -> /system/product -> /product. Every path lookup under
# /product then returns ELOOP, first-stage init cannot mount the product and
# system_ext logical partitions, and init reboots into the bootloader with no
# console and no adb.
#
# Wipe the whole staging root so ninja re-creates everything under it from
# scratch. Do not delete just the two symlinks: the "mkdir -p" that would
# replace them only runs when init.environ.rc is reinstalled.
$(call add-clean-step, rm -rf $(PRODUCT_OUT)/root)
