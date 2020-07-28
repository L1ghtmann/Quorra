#import "TheGrid.h"

@interface FlynnsArcade : NSObject
+ (FlynnsArcade*)sharedInstance;
- (TheGrid*)container;
-(void)initiateGrid;
@property (nonatomic,readwrite) BOOL gpsIsActive; 
@property (nonatomic,readwrite) BOOL micIsActive; 
@property (nonatomic,readwrite) BOOL cameraIsActive; 
@end