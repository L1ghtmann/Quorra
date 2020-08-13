#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSListController (Private)
- (void)_returnKeyPressed:(id)notification;
@end

@interface QuorraPrefsRootListController : PSListController
@end
