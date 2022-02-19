//
//	TheGrid.x
//	Quorra
//
//	Created by Lightmann during COVID-19
//

#import "TheGrid.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kLandWidth [UIScreen mainScreen].bounds.size.height
#define kLandHeight [UIScreen mainScreen].bounds.size.width
#define noNotch (kHeight < 812)

static UIDeviceOrientation currentOrientation;

@implementation TheGrid

-(instancetype)init {
	self = [super init];

	if (self) {
		[self setWindowLevel:2020];
		[self makeKeyAndVisible];
		[self setAlpha:0];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:NO];

		if(!self.greenDot){
			self.greenDot = [[UIView alloc] initWithFrame:CGRectZero];
			[self.greenDot setBackgroundColor:[UIColor greenColor]];
			[self.greenDot.layer setCornerRadius:2.5];
			[self.greenDot setAlpha:0];
			[self addSubview:self.greenDot];
		}

		if(!self.orangeDot){
			self.orangeDot = [[UIView alloc] initWithFrame:CGRectZero];
			[self.orangeDot setBackgroundColor:[UIColor orangeColor]];
			[self.orangeDot.layer setCornerRadius:2.5];
			[self.orangeDot setAlpha:0];
			[self addSubview:self.orangeDot];
		}

		if(!self.blueDot){
			self.blueDot = [[UIView alloc] initWithFrame:CGRectZero];
			[self.blueDot setBackgroundColor:[UIColor colorWithRed:44.0f/255.0f green:143.0f/255.0f blue:255.0f/255.0f alpha:1.0]];
			[self.blueDot.layer setCornerRadius:2.5];
			[self.blueDot setAlpha:0];
			[self addSubview:self.blueDot];
		}

		[self layoutIndicators];

		// Add self as observer for orientation change notifications (responded to below)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated) name:@"com.apple.springboard.screenchanged" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated) name:@"UIWindowDidRotateNotification" object:nil];

		// Save device's current orientation (to be referenced in later stages)
		currentOrientation = [[UIApplication sharedApplication] _frontMostAppOrientation];

		if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")) {
			// In some apps the appWindow scene is not automatically passed to TheGrid, so we have to manually grab it in order to take hold in said apps
			if(!self.windowScene && [[UIApplication sharedApplication] windows].count){
				UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
				[self setWindowScene:appWindow.windowScene];
			}
		}
	}

	return self;
}

// default position
-(void)layoutIndicators{
	if(!yPos && !xPos){ // default (centered)
		if(noNotch) {
			[self.greenDot setFrame:CGRectMake((kWidth/2)+10,17,5,5)];
			[self.orangeDot setFrame:CGRectMake((kWidth/2),17,5,5)];
			[self.blueDot setFrame:CGRectMake((kWidth/2)-10,17,5,5)];
		} else {
			[self.greenDot setFrame:CGRectMake((kWidth/2)+10,34,5,5)];
			[self.orangeDot setFrame:CGRectMake((kWidth/2),34,5,5)];
			[self.blueDot setFrame:CGRectMake((kWidth/2)-10,34,5,5)];
		}
	}
	else if(yPos != 0 && !xPos){ // y change no x
		[self.greenDot setFrame:CGRectMake((kWidth/2)+10,yPos,5,5)];
		[self.orangeDot setFrame:CGRectMake((kWidth/2),yPos,5,5)];
		[self.blueDot setFrame:CGRectMake((kWidth/2)-10,yPos,5,5)];
	}
	else if(!yPos && xPos != 0){ // x change no y
		if(noNotch) {
			[self.greenDot setFrame:CGRectMake(xPos+10,17,5,5)];
			[self.orangeDot setFrame:CGRectMake(xPos,17,5,5)];
			[self.blueDot setFrame:CGRectMake(xPos-10,17,5,5)];
		} else {
			[self.greenDot setFrame:CGRectMake(xPos+10,34,5,5)];
			[self.orangeDot setFrame:CGRectMake(xPos,34,5,5)];
			[self.blueDot setFrame:CGRectMake(xPos-10,34,5,5)];
		}
	}
	else{ // both changed
		[self.greenDot setFrame:CGRectMake(xPos+10,yPos,5,5)];
		[self.orangeDot setFrame:CGRectMake(xPos,yPos,5,5)];
		[self.blueDot setFrame:CGRectMake(xPos-10,yPos,5,5)];
	}
}

// left landscape position
-(void)landscapeLeftLayout{
	if(!landYPos && !landXPos){ // default (centered)
		[self.greenDot setFrame:CGRectMake(kLandWidth-10,(kLandHeight/2)+10,5,5)];
		[self.orangeDot setFrame:CGRectMake(kLandWidth-10,(kLandHeight/2),5,5)];
		[self.blueDot setFrame:CGRectMake(kLandWidth-10,(kLandHeight/2)-10,5,5)];
	}
	else if(landYPos != 0 && !landXPos){ // y change no x
		[self.greenDot setFrame:CGRectMake(kLandWidth-landYPos,(kLandHeight/2)+10,5,5)];
		[self.orangeDot setFrame:CGRectMake(kLandWidth-landYPos,(kLandHeight/2),5,5)];
		[self.blueDot setFrame:CGRectMake(kLandWidth-landYPos,(kLandHeight/2)-10,5,5)];
	}
	else if(!landYPos && landXPos != 0){ // x change no y
		[self.greenDot setFrame:CGRectMake(kLandWidth-10,landXPos+30,5,5)];
		[self.orangeDot setFrame:CGRectMake(kLandWidth-10,landXPos+20,5,5)];
		[self.blueDot setFrame:CGRectMake(kLandWidth-10,landXPos+10,5,5)];
	}
	else{ // both changed
		[self.greenDot setFrame:CGRectMake(kLandWidth-landYPos,landXPos+30,5,5)];
		[self.orangeDot setFrame:CGRectMake(kLandWidth-landYPos,landXPos+20,5,5)];
		[self.blueDot setFrame:CGRectMake(kLandWidth-landYPos,landXPos+10,5,5)];
	}
}

// right landscape position
-(void)landscapeRightLayout{
	if(!landYPos && !landXPos){ // default (centered)
		[self.greenDot setFrame:CGRectMake(10,(kLandHeight/2)+10,5,5)];
		[self.orangeDot setFrame:CGRectMake(10,(kLandHeight/2),5,5)];
		[self.blueDot setFrame:CGRectMake(10,(kLandHeight/2)-10,5,5)];
	}
	else if(landYPos != 0 && !landXPos){ // y change no x
		[self.greenDot setFrame:CGRectMake(landYPos,(kLandHeight/2)+10,5,5)];
		[self.orangeDot setFrame:CGRectMake(landYPos,(kLandHeight/2)-10,5,5)];
		[self.blueDot setFrame:CGRectMake(landYPos,(kLandHeight/2)-10,5,5)];
	}
	else if(!landYPos && landXPos != 0){ // x change no y
		[self.greenDot setFrame:CGRectMake(10,(kLandHeight-landXPos-30),5,5)];
		[self.orangeDot setFrame:CGRectMake(10,(kLandHeight-landXPos-20),5,5)];
		[self.blueDot setFrame:CGRectMake(10,(kLandHeight-landXPos-10),5,5)];
	}
	else{ // both changed
		[self.greenDot setFrame:CGRectMake(landYPos,(kLandHeight-landXPos-30),5,5)];
		[self.orangeDot setFrame:CGRectMake(landYPos,(kLandHeight-landXPos-20),5,5)];
		[self.blueDot setFrame:CGRectMake(landYPos,(kLandHeight-landXPos-10),5,5)];
	}
}

-(void)gridPowerOn{
	[UIView animateWithDuration:0.5 animations:^{
		[self setAlpha:1];
	}];
}

-(void)gridPowerOff{
	[UIView animateWithDuration:0.5 animations:^{
		[self setAlpha:0];
	}];
}

// deal with rotation and hiding when in landscape
-(void)rotated{
	// check if orientation has actually changed and if not, ignore
	if(currentOrientation == [[UIApplication sharedApplication] _frontMostAppOrientation]){
		return;
	}

	// if it did, save the current orientation and act accordingly
	currentOrientation = [[UIApplication sharedApplication] _frontMostAppOrientation];

	switch(currentOrientation){
		case UIDeviceOrientationPortrait:
			if(noLandDots) [self gridPowerOn];
			[self layoutIndicators];
		break;

		case UIDeviceOrientationLandscapeLeft:
			if(noLandDots)
				[self gridPowerOff];
			else
				[self landscapeLeftLayout];
		break;

		case UIDeviceOrientationLandscapeRight:
			if(noLandDots)
				[self gridPowerOff];
			else
				[self landscapeRightLayout];
		break;

		default:
		break;
	};
}

// allows TheGrid to display when the device is still locked (for LS camera)
+(BOOL)_isSecure{
	return YES;
}

// prevents TheGrid from taking control of the status bar
-(BOOL)_canAffectStatusBarAppearance{
	return NO;
}

@end


//	PREFERENCES
void otherPreferencesChanged(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lightmann.quorraprefs"];
	isEnabled2 = (prefs && [prefs objectForKey:@"isEnabled"] ? [[prefs valueForKey:@"isEnabled"] boolValue] : YES );
	noLandDots = (prefs && [prefs objectForKey:@"noLandDots"] ? [[prefs valueForKey:@"noLandDots"] boolValue] : NO );
	yPos = (prefs && [prefs objectForKey:@"yPos"] ? [[prefs valueForKey:@"yPos"] integerValue] : 0 );
	xPos = (prefs && [prefs objectForKey:@"xPos"] ? [[prefs valueForKey:@"xPos"] integerValue] : 0 );
	landYPos = (prefs && [prefs objectForKey:@"landYPos"] ? [[prefs valueForKey:@"landYPos"] integerValue] : 0 );
	landXPos = (prefs && [prefs objectForKey:@"landXPos"] ? [[prefs valueForKey:@"landXPos"] integerValue] : 0 );
}

%ctor {
	if ([[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"] || [[NSProcessInfo processInfo].processName isEqualToString:@"SpringBoard"]) {
		otherPreferencesChanged();

		if(isEnabled2){
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)otherPreferencesChanged, CFSTR("me.lightmann.quorraprefs-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		}
	}
}
