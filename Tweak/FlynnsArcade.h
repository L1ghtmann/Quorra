#import "TheGrid.h"

@interface FlynnsArcade : NSObject 
+(instancetype)sharedInstance;
-(TheGrid *)grid;
@end
