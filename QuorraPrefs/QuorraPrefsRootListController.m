#include "QuorraPrefsRootListController.h"
#import <spawn.h>

@implementation QuorraPrefsRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

// close out of textfield when return key is pressed
- (void)_returnKeyPressed:(id)notification {
	[self.view endEditing:YES];
	[super _returnKeyPressed:notification];
}

- (void)viewWillAppear:(BOOL)animated {
	if(self.view.traitCollection.userInterfaceStyle == 1){ //light mode enabled
		[[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed:16.0f/255.0f green:16.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];
	}
	else{
		[[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed:247.0f/255.0f green:249.0f/255.0f blue:250.0f/255.0f alpha:1.0]];
	}
	[super viewWillAppear:animated];
}

- (void)respring:(id)sender {
	pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
}

@end
