#include "QuorraPrefsRootListController.h"
#import <spawn.h>

@implementation QuorraPrefsRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

//tints color of Switches
- (void)viewWillAppear:(BOOL)animated {
	[[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed:247.0f/255.0f green:249.0f/255.0f blue:250.0f/255.0f alpha:1.0]];
    [super viewWillAppear:animated];
}

//close out of textfield when return key is pressed
- (void)_returnKeyPressed:(id)notification {
	[self.view endEditing:YES];
	[super _returnKeyPressed:notification];
}

//sbreload > respring
- (void)respring:(id)sender {
	pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, "usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
}

@end
