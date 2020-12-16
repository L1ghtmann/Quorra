#import "TheGrid.h"
#import <notify.h>

#define kWidth [UIScreen mainScreen].bounds.size.width 
#define kHeight [UIScreen mainScreen].bounds.size.height
#define noNotch (kHeight < 812)

@implementation TheGrid

-(TheGrid *)init {
	self = [super init];

	if (self) {		
		[self setWindowLevel:2020];
		[self makeKeyAndVisible];
		[self setAlpha:0];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:NO];
		[self _setSecure: YES]; //Prevents window to exist when device is locked (http://iphonedevwiki.net/index.php/Updating_extensions_for_iOS_8)

		if(!self.greenDot){
			self.greenDot = [[UIView alloc] initWithFrame:CGRectZero];
			self.greenDot.backgroundColor = [UIColor greenColor];
			[self.greenDot setAlpha:0];
			[self addSubview:self.greenDot];
		}

		if(!self.orangeDot){			
			self.orangeDot = [[UIView alloc] initWithFrame:CGRectZero];
			self.orangeDot.backgroundColor = [UIColor orangeColor];
			[self.orangeDot setAlpha:0];
			[self addSubview:self.orangeDot];
		}

		if(!self.blueDot){
			self.blueDot = [[UIView alloc] initWithFrame:CGRectZero];
			self.blueDot.backgroundColor = [UIColor colorWithRed:44.0f/255.0f green:143.0f/255.0f blue:255.0f/255.0f alpha:1.0]; 
			[self.blueDot setAlpha:0];
			[self addSubview:self.blueDot];
		}

		int notify_token2;

			notify_register_dispatch("me.lightmann.quorra/camActive", &notify_token2, dispatch_get_main_queue(), ^(int token){
				[UIView animateWithDuration:0.5 animations:^{
					[[self greenDot] setAlpha:1];
    			}];
			});
			notify_register_dispatch("me.lightmann.quorra/camInactive", &notify_token2, dispatch_get_main_queue(), ^(int token){
				[UIView animateWithDuration:0.5 animations:^{
					[[self greenDot] setAlpha:0];
    			}];
			});
	

			notify_register_dispatch("me.lightmann.quorra/micActive", &notify_token2, dispatch_get_main_queue(), ^(int token){
				[UIView animateWithDuration:0.5 animations:^{
					[[self orangeDot] setAlpha:1];
    			}];
			});
			notify_register_dispatch("me.lightmann.quorra/micInactive", &notify_token2, dispatch_get_main_queue(), ^(int token){
				[UIView animateWithDuration:0.5 animations:^{
					[[self orangeDot] setAlpha:0];
    			}];
			});
		

			notify_register_dispatch("me.lightmann.quorra/gpsActive", &notify_token2, dispatch_get_main_queue(), ^(int token){
				[UIView animateWithDuration:0.5 animations:^{
					[[self blueDot] setAlpha:1];
    			}];
			});
			notify_register_dispatch("me.lightmann.quorra/gpsInactive", &notify_token2, dispatch_get_main_queue(), ^(int token){
				[UIView animateWithDuration:0.5 animations:^{
					[[self blueDot] setAlpha:0];
    			}];
			});

		[self layoutIndicators];

		//Add self as observe for orientation change notifications. Responded to below
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];

    	if(kCFCoreFoundationVersionNumber >= 1600) {			
			// In some apps the appWindow scene is not automatically passed to TheGrid, so we have to manually grab it in order to take hold in said app(s)
			if(!self.windowScene && [[UIApplication sharedApplication] windows].count){
				UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
				self.windowScene = appWindow.windowScene;
			}
		}
	}
	
	return self;
}

//set default position and corner radius
-(void)layoutIndicators{
	if(!yPos && !xPos){ //default (centered)
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
	else if(yPos != 0 && !xPos){ //y change no x
		[self.greenDot setFrame:CGRectMake((kWidth/2)+10,yPos,5,5)];
		[self.orangeDot setFrame:CGRectMake((kWidth/2),yPos,5,5)];
		[self.blueDot setFrame:CGRectMake((kWidth/2)-10,yPos,5,5)]; 
	}
	else if(!yPos && xPos != 0){ //x change no y
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
	else{ //both changed
		[self.greenDot setFrame:CGRectMake(xPos+10,yPos,5,5)];
		[self.orangeDot setFrame:CGRectMake(xPos,yPos,5,5)];
		[self.blueDot setFrame:CGRectMake(xPos-10,yPos,5,5)]; 
	}	

	self.greenDot.layer.cornerRadius = self.greenDot.frame.size.height/2;
	self.orangeDot.layer.cornerRadius = self.greenDot.frame.size.height/2;
	self.blueDot.layer.cornerRadius = self.greenDot.frame.size.height/2;
}

//positioning for left landscape 
-(void)landscapeLeftLayout{
	if(!landYPos && !landXPos){ //default (centered)
		[self.greenDot setFrame:CGRectMake(kWidth-10,(kHeight/2)+10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(kWidth-10,(kHeight/2),5,5)]; 
		[self.blueDot setFrame:CGRectMake(kWidth-10,(kHeight/2)-10,5,5)]; 
	}
	else if(landYPos != 0 && !landXPos){ //y change no x
		[self.greenDot setFrame:CGRectMake(kWidth-landYPos,(kHeight/2)+10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(kWidth-landYPos,(kHeight/2),5,5)]; 
		[self.blueDot setFrame:CGRectMake(kWidth-landYPos,(kHeight/2)-10,5,5)]; 
	}
	else if(!landYPos && landXPos != 0){ //x change no y
		[self.greenDot setFrame:CGRectMake(kWidth-10,landXPos+30,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(kWidth-10,landXPos+20,5,5)]; 
		[self.blueDot setFrame:CGRectMake(kWidth-10,landXPos+10,5,5)]; 
	}
	else{ //both changed
		[self.greenDot setFrame:CGRectMake(kWidth-landYPos,landXPos+30,5,5)];
		[self.orangeDot setFrame:CGRectMake(kWidth-landYPos,landXPos+20,5,5)];
		[self.blueDot setFrame:CGRectMake(kWidth-landYPos,landXPos+10,5,5)]; 
	}	
}

//positioning for right landscape 
-(void)landscapeRightLayout{
	if(!landYPos && !landXPos){ //default (centered)
		[self.greenDot setFrame:CGRectMake(10,(kHeight/2)+10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(10,(kHeight/2),5,5)]; 
		[self.blueDot setFrame:CGRectMake(10,(kHeight/2)-10,5,5)]; 
	}
	else if(landYPos != 0 && !landXPos){ //y change no x
		[self.greenDot setFrame:CGRectMake(landYPos,(kHeight/2)+10,5,5)];
		[self.orangeDot setFrame:CGRectMake(landYPos,(kHeight/2)-10,5,5)];
		[self.blueDot setFrame:CGRectMake(landYPos,(kHeight/2)-10,5,5)]; 
	}
	else if(!landYPos && landXPos != 0){ //x change no y
		[self.greenDot setFrame:CGRectMake(10,(kHeight-landXPos-30),5,5)];
		[self.orangeDot setFrame:CGRectMake(10,(kHeight-landXPos-20),5,5)];
		[self.blueDot setFrame:CGRectMake(10,(kHeight-landXPos-10),5,5)]; 
	}
	else{ //both changed
		[self.greenDot setFrame:CGRectMake(landYPos,(kHeight-landXPos-30),5,5)];
		[self.orangeDot setFrame:CGRectMake(landYPos,(kHeight-landXPos-20),5,5)];
		[self.blueDot setFrame:CGRectMake(landYPos,(kHeight-landXPos-10),5,5)]; 
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

//deal with rotation and hiding in landscape
-(void)rotated:(NSNotification *)notification {
	UIDevice * device = notification.object;

	switch(device.orientation){
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

//prevents TheGrid from taking control of the status bar 
-(BOOL)_canAffectStatusBarAppearance{
	return NO;
}

@end


//	PREFERENCES 
void otherPreferencesChanged(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lightmann.quorraprefs"];

	noLandDots = (prefs && [prefs objectForKey:@"noLandDots"] ? [[prefs valueForKey:@"noLandDots"] boolValue] : NO );
	yPos = (prefs && [prefs objectForKey:@"yPos"] ? [[prefs valueForKey:@"yPos"] integerValue] : 0 );
	xPos = (prefs && [prefs objectForKey:@"xPos"] ? [[prefs valueForKey:@"xPos"] integerValue] : 0 );
	landYPos = (prefs && [prefs objectForKey:@"landYPos"] ? [[prefs valueForKey:@"landYPos"] integerValue] : 0 );
	landXPos = (prefs && [prefs objectForKey:@"landXPos"] ? [[prefs valueForKey:@"landXPos"] integerValue] : 0 );
}

%ctor {
	otherPreferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)otherPreferencesChanged, CFSTR("me.lightmann.quorraprefs-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
