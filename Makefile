DEBUG=0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Quorra

Quorra_FILES = Tweak/FlynnsArcade.x Tweak/TheGrid.x Tweak/Tweak.xm
Quorra_LIBRARIES = mryipc
Quorra_PRIVATE_FRAMEWORKS = BulletinBoard
Quorra_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += quorraprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "sbreload"