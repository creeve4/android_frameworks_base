du_device := $(patsubst %f,%,$(subst du_,,$(TARGET_PRODUCT)))
ifneq ($(filter crosshatch emulator,$(du_device)),)
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_RRO_THEME := DisplayCutoutEmulationNarrow


LOCAL_PRODUCT_MODULE := true

LOCAL_SRC_FILES := $(call all-subdir-java-files)

LOCAL_RESOURCE_DIR := $(LOCAL_PATH)/res

LOCAL_PACKAGE_NAME := DisplayCutoutEmulationNarrowOverlay
LOCAL_SDK_VERSION := current

include $(BUILD_RRO_PACKAGE)
endif
