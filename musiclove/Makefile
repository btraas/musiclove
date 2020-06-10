GO_EASY_ON_ME=1
include $(THEOS)/makefiles/common.mk

# ARCHS = arm64 arm64e
# TARGET = iphone:clang:9.3:latest

# SYSROOT = $(THEOS)/sdks/iPhoneOS9.3.sdk
TARGET = iphone:clang:11.2


BUNDLE_NAME = MusicLove
MusicLove_FILES = MLVRootListController.m
MusicLove_INSTALL_PATH = /Library/PreferenceBundles
MusicLove_FRAMEWORKS = UIKit
MusicLove_PRIVATE_FRAMEWORKS = Preferences
MusicLove_LIBRARIES = colorpicker


include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MusicLove.plist$(ECHO_END)
