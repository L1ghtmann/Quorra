#import "TheGrid.h"
#import "Headers.h"

// @interface FlynnsArcade : NSObject
@interface FlynnsArcade : UIViewController
+ (FlynnsArcade*)sharedInstance;
- (TheGrid*)container;
-(void)initiateGrid;
@property (nonatomic,readwrite) BOOL gpsIsActive; 
@property (nonatomic,readwrite) BOOL micIsActive; 
@property (nonatomic,readwrite) BOOL cameraIsActive; 
@end