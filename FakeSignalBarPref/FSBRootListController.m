#import <Preferences/PSSpecifier.h>

#include <spawn.h>
#include <signal.h>

#include "FSBRootListController.h"

static NSString *prefsFileName = @"alias20.fakesignalbar";

@implementation FSBRootListController

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/jb/User/Library/Preferences/%@.plist", prefsFileName];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/jb/User/Library/Preferences/%@.plist", prefsFileName];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)doRespring {
	pid_t pid;
	int status;
	const char *argv[] = {"sbreload", NULL};
	posix_spawn(&pid, "/var/jb/usr/bin/sbreload", NULL, NULL, (char* const*)argv, NULL);
	waitpid(pid, &status, WEXITED);
}

- (void)respring {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Do you really want to respring now?" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self doRespring];
    }];
    
    [alertController addAction:destructiveAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}




@end
