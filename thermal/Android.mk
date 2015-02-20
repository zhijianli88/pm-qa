include $(call all-subdir-makefiles)
LOCAL_PATH:= $(call my-dir)

module_name = thermal

define $(module_name)_add_executable
    include $(CLEAR_VARS)
    LOCAL_MODULE_TAGS := optional 
    LOCAL_MODULE_CLASS := tests
    LOCAL_MODULE := $1.sh
    systemtarball: $1.sh
    systemimage: $1.sh
    LOCAL_SRC_FILES := $1.sh
    LOCAL_MODULE_PATH := $(TARGET_OUT_EXECUTABLES)/pm-qa/$(module_name)
    include $(BUILD_PREBUILT)
endef

test_num := sanity 01 02 03 04 05 06
$(foreach item,$(test_num),$(eval $(call $(module_name)_add_executable, $(module_name)_$(item))))
