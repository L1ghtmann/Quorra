#import <Preferences/PSListController.h>

@interface PSListController (Private)
- (void)_returnKeyPressed:(id)notification;
@end

@interface QuorraPrefsRootListController : PSListController
@end
