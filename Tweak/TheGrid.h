#import <UIKit/UIKit.h>

// https://stackoverflow.com/a/5337804
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface UIApplication (Private)
-(UIDeviceOrientation)_frontMostAppOrientation;
@end

@interface UIWindow (Private)
+(BOOL)_isSecure;
-(BOOL)_canAffectStatusBarAppearance;
@end

@interface TheGrid : UIWindow
@property (nonatomic,retain) UIView * blueDot;
@property (nonatomic,retain) UIView * orangeDot;
@property (nonatomic,retain) UIView * greenDot;
-(void)layoutIndicators;
-(void)landscapeLeftLayout;
-(void)landscapeRightLayout;
-(void)gridPowerOn;
-(void)gridPowerOff;
-(void)rotated;
@end

// prefs
static BOOL isEnabled2;
static BOOL noLandDots;
static int yPos;
static int xPos;
static int landYPos;
static int landXPos;
