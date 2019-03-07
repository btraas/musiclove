include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MusicLove
MusicLove_FILES = MLVRootListController.m
MusicLove_INSTALL_PATH = /Library/PreferenceBundles
MusicLove_FRAMEWORKS = UIKit
MusicLove_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MusicLove.plist$(ECHO_END)
