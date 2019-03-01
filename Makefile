include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MusicLove
MusicLove_FILES = Main.xm
MusicLove_FRAMEWORKS = MediaPlayer UIKit
MusicLove_PrivateFrameworks = FuseUI MediaPlaybackCore MediaPlayerUI MediaRemote

BUNDLE_NAME = ca.btraas.musiclove
ca.btraas.musiclove_INSTALL_PATH = /Library/Application Support/
# ca.btraas.musiclove_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Music" || echo "Music was not running." && printf "\nEnjoy MusicLove ~\n"
