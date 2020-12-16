#import <UIKit/UIKit.h>

@interface UIWindow (Private)
-(void)_setSecure:(BOOL)secure;
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
-(void)rotated:(NSNotification *)notification;
@end

//prefs
static BOOL noLandDots;

static int yPos;
static int xPos;

static int landYPos;
static int landXPos;
