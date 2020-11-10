#import <UIKit/UIKit.h>

static int yPos;
static int xPos;

@interface UIWindow (Private)
-(void)_setSecure:(BOOL)secure;
-(BOOL)_canAffectStatusBarAppearance;
@end

@interface TheGrid : UIWindow
@property (nonatomic,retain) UIView * blueDot; 
@property (nonatomic,retain) UIView * orangeDot; 
@property (nonatomic,retain) UIView * greenDot; 
@end

// @interface SpringBoard : UIApplication
// +(id) sharedApplication;
// -(NSInteger) activeInterfaceOrientation;
// @end
