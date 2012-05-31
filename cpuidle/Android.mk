include $(call all-subdir-makefiles)
LOCAL_PATH:= $(call my-dir)

module_name = cpuidle

define $(module_name)_add_executable
    include $(CLEAR_VARS)
    LOCAL_MODULE_TAGS := optional 
    LOCAL_MODULE_CLASS := tests
    LOCAL_MODULE := $1.sh
    LOCAL_SRC_FILES := $1.sh
    LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)/pm-qa/$(module_name)
    include $(BUILD_PREBUILT)
endef

test_num := 01 02 03
$(foreach item,$(test_num),$(eval $(call $(module_name)_add_executable, $(module_name)_$(item))))

include $(CLEAR_VARS)
LOCAL_MODULE := cpuidle_killer
LOCAL_SRC_FILES:= cpuidle_killer.c
LOCAL_STATIC_LIBRARIES := libcutils libc 
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)/pm-qa/$(module_name)
include $(BUILD_EXECUTABLE)
