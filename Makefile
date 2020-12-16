DEBUG=0
ARCHS = arm64 arm64e
TARGET = iphone:clang::12.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Quorra

Quorra_FILES = Tweak/Tweak.xm Tweak/FlynnsArcade.m Tweak/TheGrid.x
Quorra_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += quorraprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "sbreload"