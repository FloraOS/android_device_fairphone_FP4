# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Fairphone B.V.

allowed_list += product_manifest.xml Browser2

# Include the device specific makefile
$(call inherit-product, device/fairphone/FP4/device.mk)

$(call enforce-product-packages-exist,$(allowed_list))
