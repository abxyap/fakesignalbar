DEBUG=0
FINALPACKAGE=1
GO_EASY_ON_ME=1

THEOS_PACKAGE_SCHEME = rootless

THEOS_USE_NEW_ABI=1
TARGET = iphone:14.5:14.5
ARCHS = arm64 arm64e

THEOS_DEVICE_IP = 127.0.0.1 -p 2222

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FakeSignalBarPref

FakeSignalBarPref_FILES = FSBRootListController.m
FakeSignalBarPref_INSTALL_PATH = /Library/PreferenceBundles
FakeSignalBarPref_FRAMEWORKS = UIKit
FakeSignalBarPref_PRIVATE_FRAMEWORKS = Preferences
FakeSignalBarPref_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FakeSignalBarPref.plist$(ECHO_END)
