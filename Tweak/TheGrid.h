#import <UIKit/UIKit.h>

@interface UIWindow (Private)
-(void)_setSecure:(BOOL)secure;
-(BOOL)_canAffectStatusBarAppearance;
@end

@interface TheGrid : UIWindow
@property (nonatomic,retain) UIView * blueDot; 
@property (nonatomic,retain) UIView * orangeDot; 
@property (nonatomic,retain) UIView * greenDot; 
@end

//prefs
static int yPos;
static int xPos;

static int landYPos;
static int landXPos;

static BOOL noLandDots;
