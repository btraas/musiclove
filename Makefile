FINALPACKAGE=0
DEBUG=1

PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)

# TARGET = iphone:clang:latest:13.0



include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MusicLove
MusicLove_FILES = Main.xm
MusicLove_FRAMEWORKS = MediaPlayer UIKit
#MusicLove_PrivateFrameworks = FuseUI MediaPlaybackCore MediaPlayerUI MediaRemote

BUNDLE_NAME = ca.btraas.musiclove
ca.btraas.musiclove_INSTALL_PATH = /Library/Application Support/
ca.btraas.musiclove_LIBRARIES = colorpicker
ca.btraas.musiclove_PRIVATE_FRAMEWORKS = HomeSharing MusicLibrary


# ca.btraas.musiclove_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

INSTALL_TARGET_PROCESSES = Music

after-install::
	install.exec "killall -9 Music" || echo "Music was not running." && printf "\nEnjoy MusicLove ~\n" # && install.exec "killall -9 SpringBoard"

SUBPROJECTS += musiclove #settings
include $(THEOS_MAKE_PATH)/aggregate.mk
