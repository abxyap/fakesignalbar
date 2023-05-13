DEBUG=0
FINALPACKAGE=1
GO_EASY_ON_ME=1

THEOS_PACKAGE_SCHEME = rootless

TARGET = iphone:14.5:14.5
ARCHS = arm64 arm64e

THEOS_DEVICE_IP = 127.0.0.1 -p 2222
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FakeSignalBar

FakeSignalBar_FILES = Tweak.xm
FakeSignalBar_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += FakeSignalBarPref
include $(THEOS_MAKE_PATH)/aggregate.mk
