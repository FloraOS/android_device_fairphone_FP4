# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 FairPhone B.V.

#----------------------------------------------------------------------
# Configs common to AndroidBoard.mk for all targets
#----------------------------------------------------------------------
include vendor/qcom/opensource/core-utils/build/AndroidBoardCommon.mk


#----------------------------------------------------------------------
# extra images
#----------------------------------------------------------------------
include $(FP_PATH)/generate_extra_images.mk
