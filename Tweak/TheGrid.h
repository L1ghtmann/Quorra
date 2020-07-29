#import <UIKit/UIKit.h>

@interface UIWindow (Private)
-(void)_setSecure:(BOOL)secure;
@end

@interface TheGrid : UIWindow
@property (nonatomic,retain) UIView * greenDot; 
@property (nonatomic,retain) UIView * yellowDot; 
@property (nonatomic,retain) UIView * redDot; 
@end