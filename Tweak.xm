#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach-o/dyld_images.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <sys/stat.h>

/* Config Start */
static BOOL kEnabled;

static BOOL kEnabledSim1Carrier;
static NSString *kSim1Carrier;
static BOOL kEnabledSim1Label;
static NSString *kSim1Label;
static BOOL kEnabledSim1Strength;
static int kSim1Strength;
static BOOL kEnabledSim1CelluarType;
static int kSim1CelluarType;

static BOOL kEnabledActivatedSim2;
static BOOL kEnabledSim2Carrier;
static NSString *kSim2Carrier;
static BOOL kEnabledSim2Label;
static NSString *kSim2Label;
static BOOL kEnabledSim2Strength;
static int kSim2Strength;
static BOOL kEnabledSim2CelluarType;
static int kSim2CelluarType;
/* Config End */

@interface STTelephonyStatusDomainSIMInfo : NSObject {
	BOOL _SIMPresent;
	NSString* _label;
	NSString* _shortLabel;
	unsigned long long _signalStrengthBars;
	unsigned long long _maxSignalStrengthBars;
	unsigned long long _serviceState;
	unsigned long long _cellularServiceState;
	NSString* _serviceDescription;
	NSString* _secondaryServiceDescription;
	unsigned long long _dataNetworkType;
	BOOL _providingDataConnection;
	BOOL _preferredForDataConnections;
	BOOL _registeredWithoutCellular;
	BOOL _callForwardingEnabled;
}
@end

@interface STTelephonySubscriptionInfo : NSObject {
	NSString* _identifier;
	NSString* _SIMLabel;
	NSString* _shortSIMLabel;
	NSString* _SIMStatus;
	unsigned long long _registrationStatus;
	unsigned long long _cellularRegistrationStatus;
	unsigned long long _dataConnectionType;
	BOOL _preferredForDataConnections;
	BOOL _providingDataConnection;
	BOOL _registeredWithoutCellular;
	unsigned long long _signalStrengthBars;
	unsigned long long _maxSignalStrengthBars;
	NSString* _operatorName;
	NSString* _lastKnownNetworkCountryCode;
	unsigned long long _callForwardingIndicator;
	BOOL _networkReselectionNeeded;
	long long _registrationRejectionCauseCode;
}
@end

@interface STMutableTelephonySubscriptionInfo : STTelephonySubscriptionInfo
@end

@interface STTelephonySubscriptionContext : NSObject {
	STMutableTelephonySubscriptionInfo* _subscriptionInfo;
}
@end

@interface STTelephonyStateProvider : NSObject {
	BOOL _hasCellularTelephony;
	BOOL _cachedDualSIMEnabled;
	BOOL _cachedRadioModuleDead;
	BOOL _containsCellularRadio;
	BOOL _airplaneModeEnabled;
	STTelephonySubscriptionContext* _slot1SubscriptionContext;
	STTelephonySubscriptionContext* _slot2SubscriptionContext;
	NSArray* _cachedCTContexts;
	long long _cachedSuppressesCellDataIndicator;
	long long _cachedSuppressesCellIndicators;
	long long _cachedNeedsUserIdentificationModule;
	BOOL* _telephonyDaemonRestartHandlerCanceled;
}
-(void)_setSignalStrengthBars:(unsigned long long)arg1 maxBars:(unsigned long long)arg2 inSubscriptionContext:(id)arg3 ;
-(void)_updateState;
-(void)subscriptionInfoDidChange;
-(void)_updateRegistrationNowInSubscriptionContext:(id)arg1 ;

@end

%group FakeSignalBarHooks 
%hook STTelephonyStateProvider
-(STTelephonySubscriptionInfo *)subscriptionInfoForSlot:(long long)arg1 {
	STTelephonySubscriptionInfo *ret = %orig;

	if(!ret)
		return ret;

	// 14=5GUC ,13=5GUW , 12=5G+, 11=5G, 10=5Ge, 9=LTE+, 8=LTE-A, 7 = LTE, 6 = 4G, 5 & 4 = 3G, 3 = EDGE, 2 = GPRS, 1 = 1x, 0 = Blank
	if(arg1 == 1) {
		MSHookIvar<NSString *>(ret, "_SIMStatus") = @"kCTSIMSupportSIMStatusReady";
		MSHookIvar<unsigned long long>(ret, "_registrationStatus") = 2; //registered
		MSHookIvar<unsigned long long>(ret, "_cellularRegistrationStatus") = 2;

		if(kEnabledSim1Strength)
			MSHookIvar<unsigned long long>(ret, "_signalStrengthBars") = kSim1Strength;
		if(kEnabledSim1Carrier)
			MSHookIvar<NSString *>(ret, "_operatorName") = kSim1Carrier;
		if(kEnabledSim1CelluarType)
			MSHookIvar<int>(ret, "_dataConnectionType") = kSim1CelluarType;
	}

	if(arg1 == 2 && kEnabledActivatedSim2) {
		MSHookIvar<NSString *>(ret, "_SIMStatus") = @"kCTSIMSupportSIMStatusReady";
		MSHookIvar<unsigned long long>(ret, "_registrationStatus") = 2; //registered
		MSHookIvar<unsigned long long>(ret, "_cellularRegistrationStatus") = 2;

		if(kEnabledSim2Strength)
			MSHookIvar<unsigned long long>(ret, "_signalStrengthBars") = kSim2Strength;
		if(kEnabledSim2Carrier)
			MSHookIvar<NSString *>(ret, "_operatorName") = kSim2Carrier;
		if(kEnabledSim2CelluarType)
			MSHookIvar<int>(ret, "_dataConnectionType") = kSim2CelluarType;
	}
	return ret;
}

//Enable ESIM
-(BOOL)isSIMPresentForSlot:(long long)arg1 {
	BOOL ret = %orig;
	//ESIM
	if(arg1 == 2 && kEnabledActivatedSim2)
		return true;
	return ret;
}
%end


//Set ServName if fake esim attached
%hook STMutableTelephonyStatusDomainData
-(void)setSIMOneInfo:(STTelephonyStatusDomainSIMInfo *)arg1 {
	if(kEnabledSim1Label) {
		MSHookIvar<NSString *>(arg1, "_label") = kSim1Label;
		MSHookIvar<NSString *>(arg1, "_shortLabel") = kSim1Label;
	}
	%orig(arg1);
}
-(void)setSIMTwoInfo:(STTelephonyStatusDomainSIMInfo *)arg1 {
	if(kEnabledSim2Label) {
		MSHookIvar<NSString *>(arg1, "_label") = kSim2Label;
		MSHookIvar<NSString *>(arg1, "_shortLabel") = kSim2Label;
	}
	%orig(arg1);
}
%end
%end

%ctor {
	@autoreleasepool {
		NSLog(@"[FakeBar] Loaded.");

		NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/jb/var/mobile/Library/Preferences/alias20.fakesignalbar.plist"];
		if(!preferences)
			return;

		kEnabled = [[preferences objectForKey:@"enabled"] boolValue];
		if(!kEnabled)
			return;

		if([preferences objectForKey:@"enabledSim1Carrier"])	kEnabledSim1Carrier = [[preferences objectForKey:@"enabledSim1Carrier"] boolValue];
		else	kEnabledSim1Carrier = false;
		if([preferences objectForKey:@"sim1Carrier"])	kSim1Carrier = [[preferences objectForKey:@"sim1Carrier"] stringValue];
		else	kSim1Carrier = @"";
		if([preferences objectForKey:@"enabledSim1Label"])	kEnabledSim1Label = [[preferences objectForKey:@"enabledSim1Label"] boolValue];
		else	kEnabledSim1Label = false;
		if([preferences objectForKey:@"sim1Label"])	kSim1Label = [[preferences objectForKey:@"sim1Label"] stringValue];
		else	kSim1Label = @"";
		if([preferences objectForKey:@"enabledSim1Strength"])	kEnabledSim1Strength = [[preferences objectForKey:@"enabledSim1Strength"] boolValue];
		else	kEnabledSim1Strength = false;
		if([preferences objectForKey:@"sim1Strength"])	kSim1Strength = [[preferences objectForKey:@"sim1Strength"] intValue];
		else	kSim1Strength = 4;
		if([preferences objectForKey:@"enabledSim1CelluarType"])	kEnabledSim1CelluarType = [[preferences objectForKey:@"enabledSim1CelluarType"] boolValue];
		else	kEnabledSim1CelluarType = false;
		if([preferences objectForKey:@"sim1CelluarType"])	kSim1CelluarType = [[preferences objectForKey:@"sim1CelluarType"] intValue];
		else	kSim1CelluarType = 6;

		if([preferences objectForKey:@"enabledActivatedSim2"])	kEnabledActivatedSim2 = [[preferences objectForKey:@"enabledActivatedSim2"] boolValue];
		else	kEnabledActivatedSim2 = false;
		if([preferences objectForKey:@"enabledSim2Carrier"])	kEnabledSim2Carrier = [[preferences objectForKey:@"enabledSim2Carrier"] boolValue];
		else	kEnabledSim2Carrier = false;
		if([preferences objectForKey:@"sim2Carrier"])	kSim2Carrier = [[preferences objectForKey:@"sim2Carrier"] stringValue];
		else	kSim2Carrier = @"";
		if([preferences objectForKey:@"enabledSim2Label"])	kEnabledSim2Label = [[preferences objectForKey:@"enabledSim2Label"] boolValue];
		else	kEnabledSim2Label = false;
		if([preferences objectForKey:@"sim2Label"])	kSim2Label = [[preferences objectForKey:@"sim2Label"] stringValue];
		else	kSim2Label = @"";
		if([preferences objectForKey:@"enabledSim2Strength"])	kEnabledSim2Strength = [[preferences objectForKey:@"enabledSim2Strength"] boolValue];
		else	kEnabledSim2Strength = false;
		if([preferences objectForKey:@"sim2Strength"])	kSim2Strength = [[preferences objectForKey:@"sim2Strength"] intValue];
		else	kSim2Strength = 4;
		if([preferences objectForKey:@"enabledSim2CelluarType"])	kEnabledSim2CelluarType = [[preferences objectForKey:@"enabledSim2CelluarType"] boolValue];
		else	kEnabledSim2CelluarType = false;
		if([preferences objectForKey:@"sim2CelluarType"])	kSim2CelluarType = [[preferences objectForKey:@"sim2CelluarType"] intValue];
		else	kSim2CelluarType = 6;

		%init(FakeSignalBarHooks);

	}
}