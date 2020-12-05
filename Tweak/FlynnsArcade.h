#import "TheGrid.h"

@interface FlynnsArcade : UIViewController
+ (FlynnsArcade*)sharedInstance;
- (TheGrid*)container;
@end