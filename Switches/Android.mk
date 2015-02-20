LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := eng
LOCAL_MODULE_CLASS := tests
LOCAL_MODULE := Switches.sh
LOCAL_SRC_FILES := Switches.sh
LOCAL_MODULE_PATH := $(TARGET_OUT_EXECUTABLES)/pm-qa
systemimage: Switches.sh
include $(BUILD_PREBUILT)
