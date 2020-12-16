#import <UIKit/UIKit.h>
#import "TheGrid.h"

@interface FlynnsArcade : NSObject
+(FlynnsArcade*)sharedInstance;
-(TheGrid*)grid;
@end
