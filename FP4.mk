# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024-2025 FairPhone B.V.

allowed_list += product_manifest.xml Browser2

# base_system.mk asks for the ranging APEX whenever RELEASE_RANGING_STACK is
# set, but no project in this manifest defines com.android.ranging. FP4 has no
# UWB hardware, so nothing on the device needs it; drop the entry from this list
# once the module lands in the tree.
allowed_list += com.android.ranging

# Include the device specific makefile
$(call inherit-product, device/fairphone/FP4/device.mk)

ifeq ($(QCPATH),)
$(call enforce-product-packages-exist,$(allowed_list))
endif
