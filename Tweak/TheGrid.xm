#import "TheGrid.h"

#define kWidth [UIScreen mainScreen].bounds.size.width 
#define kHeight [UIScreen mainScreen].bounds.size.height
#define noNotch (kHeight < 812)

@implementation TheGrid

- (TheGrid *)init {
	self = [super init];

	if (self) {		
		self.backgroundColor = nil;
		self.windowLevel = 2020;
		[self setHidden:NO];
		self.userInteractionEnabled = NO;

		self.blueDot = [[UIView alloc] initWithFrame:CGRectZero];
		self.blueDot.backgroundColor = [UIColor colorWithRed:44.0f/255.0f green:143.0f/255.0f blue:255.0f/255.0f alpha:1.0]; 
		self.blueDot.userInteractionEnabled = NO;
		[self.blueDot setHidden:YES];
		[self addSubview:self.blueDot];
				
		self.orangeDot = [[UIView alloc] initWithFrame:CGRectZero];
		self.orangeDot.backgroundColor = [UIColor orangeColor];
		self.orangeDot.userInteractionEnabled = NO;
		[self.orangeDot setHidden:YES];
		[self addSubview:self.orangeDot];

		self.greenDot = [[UIView alloc] initWithFrame:CGRectZero];
		self.greenDot.backgroundColor = [UIColor greenColor];
		self.greenDot.userInteractionEnabled = NO;
		[self.greenDot setHidden:YES];
		[self addSubview:self.greenDot];

		[self layoutIndicators];

		//In some apps the appWindow scene is not automaticaally passed to TheGrid, so we have to manually do it so TheGrid can take hold in the application
		if(!self.windowScene && [[UIApplication sharedApplication] windows].count){
			UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
			self.windowScene = appWindow.windowScene;
		}

		//Prevents camera from flickering when device is locked (http://iphonedevwiki.net/index.php/Updating_extensions_for_iOS_8)
		if ([self respondsToSelector:@selector(_setSecure:)]){ [self _setSecure:YES]; }

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	
	return self;
}

//set default position and corner radius
-(void)layoutIndicators{
	if(!yPos && !xPos){ //default (centered)
		if(noNotch) {
			[self.blueDot setFrame:CGRectMake((kWidth/2)-10,17,5,5)]; 
			[self.orangeDot setFrame:CGRectMake((kWidth/2),17,5,5)]; 
			[self.greenDot setFrame:CGRectMake((kWidth/2)+10,17,5,5)]; 
		} else {
			[self.blueDot setFrame:CGRectMake((kWidth/2)-10,34,5,5)]; 
			[self.orangeDot setFrame:CGRectMake((kWidth/2),34,5,5)]; 
			[self.greenDot setFrame:CGRectMake((kWidth/2)+10,34,5,5)]; 
		}
	}
	else if(yPos != 0 && !xPos){ //y change no x
		[self.blueDot setFrame:CGRectMake((kWidth/2)-10,yPos,5,5)]; 
		[self.orangeDot setFrame:CGRectMake((kWidth/2),yPos,5,5)];
		[self.greenDot setFrame:CGRectMake((kWidth/2)+10,yPos,5,5)];
	}
	else if(!yPos && xPos != 0){ //x change no y
		if(noNotch) {
			[self.blueDot setFrame:CGRectMake(xPos-10,17,5,5)]; 
			[self.orangeDot setFrame:CGRectMake(xPos,17,5,5)];
			[self.greenDot setFrame:CGRectMake(xPos+10,17,5,5)];
		} else {
			[self.blueDot setFrame:CGRectMake(xPos-10,34,5,5)]; 
			[self.orangeDot setFrame:CGRectMake(xPos,34,5,5)];
			[self.greenDot setFrame:CGRectMake(xPos+10,34,5,5)];
		}
	}
	else{ //both changed
		[self.blueDot setFrame:CGRectMake(xPos-10,yPos,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(xPos,yPos,5,5)];
		[self.greenDot setFrame:CGRectMake(xPos+10,yPos,5,5)];
	}	

	self.blueDot.layer.cornerRadius = self.greenDot.frame.size.height/2;
	self.orangeDot.layer.cornerRadius = self.greenDot.frame.size.height/2;
	self.greenDot.layer.cornerRadius = self.greenDot.frame.size.height/2;
}

//positioning for left landscape 
-(void)landscapeLeftLayout{
	if(!landYPos && !landXPos){ //default (centered)
		[self.blueDot setFrame:CGRectMake(kWidth-10,(kHeight/2)-10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(kWidth-10,(kHeight/2),5,5)]; 
		[self.greenDot setFrame:CGRectMake(kWidth-10,(kHeight/2)+10,5,5)]; 
	}
	else if(landYPos != 0 && !landXPos){ //y change no x
		[self.blueDot setFrame:CGRectMake(kWidth-landYPos,(kHeight/2)-10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(kWidth-landYPos,(kHeight/2),5,5)]; 
		[self.greenDot setFrame:CGRectMake(kWidth-landYPos,(kHeight/2)+10,5,5)]; 
	}
	else if(!landYPos && landXPos != 0){ //x change no y
		[self.blueDot setFrame:CGRectMake(kWidth-10,landXPos+10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(kWidth-10,landXPos+20,5,5)]; 
		[self.greenDot setFrame:CGRectMake(kWidth-10,landXPos+30,5,5)]; 
	}
	else{ //both changed
		[self.blueDot setFrame:CGRectMake(kWidth-landYPos,landXPos+10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(kWidth-landYPos,landXPos+20,5,5)];
		[self.greenDot setFrame:CGRectMake(kWidth-landYPos,landXPos+30,5,5)];
	}	
}

//positioning for right landscape 
-(void)landscapeRightLayout{
	if(!landYPos && !landXPos){ //default (centered)
		[self.blueDot setFrame:CGRectMake(10,(kHeight/2)-10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(10,(kHeight/2),5,5)]; 
		[self.greenDot setFrame:CGRectMake(10,(kHeight/2)+10,5,5)]; 
	}
	else if(landYPos != 0 && !landXPos){ //y change no x
		[self.blueDot setFrame:CGRectMake(landYPos,(kHeight/2)-10,5,5)]; 
		[self.orangeDot setFrame:CGRectMake(landYPos,(kHeight/2)-10,5,5)];
		[self.greenDot setFrame:CGRectMake(landYPos,(kHeight/2)+10,5,5)];
	}
	else if(!landYPos && landXPos != 0){ //x change no y
		[self.blueDot setFrame:CGRectMake(10,(kHeight-landXPos-10),5,5)]; 
		[self.orangeDot setFrame:CGRectMake(10,(kHeight-landXPos-20),5,5)];
		[self.greenDot setFrame:CGRectMake(10,(kHeight-landXPos-30),5,5)];
	}
	else{ //both changed
		[self.blueDot setFrame:CGRectMake(landYPos,(kHeight-landXPos-10),5,5)]; 
		[self.orangeDot setFrame:CGRectMake(landYPos,(kHeight-landXPos-20),5,5)];
		[self.greenDot setFrame:CGRectMake(landYPos,(kHeight-landXPos-30),5,5)];
	}	
}

//if device rotates, change locations accordingly
- (void)rotated:(NSNotification *)notification {
	UIDevice * device = notification.object;

	switch(device.orientation){
		case UIDeviceOrientationPortrait: 
			if(noLandDots)
				[self setHidden:NO];
			[self layoutIndicators];
		break;

		case UIDeviceOrientationLandscapeLeft:
			if(noLandDots)
				[self setHidden:YES];
			else
				[self landscapeLeftLayout];
		break;

		case UIDeviceOrientationLandscapeRight:
			if(noLandDots)
				[self setHidden:YES];
			else
				[self landscapeRightLayout];
		break;

		default:
		break;
	};
}

//prevents my UIWindow from taking control of the status bar 
-(BOOL)_canAffectStatusBarAppearance{
	return NO;
}

@end


//	PREFERENCES 
void otherPreferencesChanged(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lightmann.quorraprefs"];
	if(prefs){
		yPos = ( [prefs objectForKey:@"yPos"] ? [[prefs valueForKey:@"yPos"] integerValue] : 0 );
		xPos = ( [prefs objectForKey:@"xPos"] ? [[prefs valueForKey:@"xPos"] integerValue] : 0 );
		landYPos = ( [prefs objectForKey:@"landYPos"] ? [[prefs valueForKey:@"landYPos"] integerValue] : 0 );
		landXPos = ( [prefs objectForKey:@"landXPos"] ? [[prefs valueForKey:@"landXPos"] integerValue] : 0 );
		noLandDots = ( [prefs objectForKey:@"noLandDots"] ? [[prefs valueForKey:@"noLandDots"] boolValue] : NO );
	}
}

%ctor {
	otherPreferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)otherPreferencesChanged, CFSTR("me.lightmann.quorraprefs-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
