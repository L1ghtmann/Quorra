#import "TheGrid.h"

// @interface FlynnsArcade : NSObject
@interface FlynnsArcade : UIViewController 
+ (FlynnsArcade*)sharedInstance;
- (TheGrid*)container;
@end