export DEBUG = 0
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:12.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Quorra

Quorra_FILES = Tweak/FlynnsArcade.x Tweak/TheGrid.x Tweak/Tweak.x
Quorra_LIBRARIES = rocketbootstrap
Quorra_PRIVATE_FRAMEWORKS = BulletinBoard
Quorra_CFLAGS = -fobjc-arc -Wno-unguarded-availability-new # since can't use @available on Linux

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += QuorraPrefs

include $(THEOS_MAKE_PATH)/aggregate.mk
