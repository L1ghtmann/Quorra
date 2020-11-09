#import "TheGrid.h"

#define kWidth [UIScreen mainScreen].bounds.size.width 
#define kHeight [UIScreen mainScreen].bounds.size.height
#define noNotch (kHeight < 812)

@implementation TheGrid

- (TheGrid *)init {
	self = [super init];

	__block UIView *blueDot;
	__block UIView *orangeDot;
	__block UIView *greenDot;

	if (self) {		
		if([NSThread isMainThread]){
			self.backgroundColor = nil;
			self.windowLevel = 2020;
			[self setHidden:NO];
			self.userInteractionEnabled = NO;


			if(!yPos && !xPos){ //default (centered)
				if(noNotch) {
					blueDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)-10,17,5,5)]; 
				} else {
					blueDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)-10,34,5,5)]; 
				}
			}
			if(yPos != 0 && !xPos){ //y change no x
				blueDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)-10,yPos,5,5)]; 
			}
			if(!yPos && xPos != 0){ //x change no y
				if(noNotch) {
					blueDot = [[UIView alloc] initWithFrame:CGRectMake(xPos-10,17,5,5)]; 
				} else {
					blueDot = [[UIView alloc] initWithFrame:CGRectMake(xPos-10,34,5,5)]; 
				}
			}
			if(yPos != 0 && xPos != 0){ //both changed
				blueDot = [[UIView alloc] initWithFrame:CGRectMake(xPos-10,yPos,5,5)]; 
			}

			blueDot.backgroundColor = [UIColor colorWithRed:44.0f/255.0f green:143.0f/255.0f blue:255.0f/255.0f alpha:1.0]; 
			blueDot.userInteractionEnabled = NO;
			blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
			[blueDot setHidden:YES];

			[self addSubview:blueDot];
			self.blueDot = blueDot;


			if(!yPos && !xPos){ //default (centered)
				if(noNotch) {
					orangeDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2),17,5,5)]; 
				} else {
					orangeDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2),34,5,5)]; 
				}
			}
			if(yPos != 0 && !xPos){ //y change no x
				orangeDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2),yPos,5,5)];
			}
			if(!yPos && xPos != 0){ //x change no y
				if(noNotch) {
					orangeDot = [[UIView alloc] initWithFrame:CGRectMake(xPos,17,5,5)];
				} else {
					orangeDot = [[UIView alloc] initWithFrame:CGRectMake(xPos,34,5,5)];
				}
			}
			if(yPos != 0 && xPos != 0){ //both changed
				orangeDot = [[UIView alloc] initWithFrame:CGRectMake(xPos,yPos,5,5)];
			}
				
			orangeDot.backgroundColor = [UIColor orangeColor];
			orangeDot.userInteractionEnabled = NO;
			orangeDot.layer.cornerRadius = orangeDot.frame.size.height/2;
			[orangeDot setHidden:YES];

			[self addSubview:orangeDot];
			self.orangeDot = orangeDot;

					
			if(!yPos && !xPos){ //default (centered)
				if(noNotch) {
					greenDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)+10,17,5,5)]; 
				} else {
					greenDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)+10,34,5,5)]; 
				}
			}
			if(yPos != 0 && !xPos){ //y change no x
				greenDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)+10,yPos,5,5)];
			}
			if(!yPos && xPos != 0){ //x change no y
				if(noNotch) {
					greenDot = [[UIView alloc] initWithFrame:CGRectMake(xPos+10,17,5,5)];
				} else {
					greenDot = [[UIView alloc] initWithFrame:CGRectMake(xPos+10,34,5,5)];
				}
			}
			if(yPos != 0 && xPos != 0){ //both changed
				greenDot = [[UIView alloc] initWithFrame:CGRectMake(xPos+10,yPos,5,5)];
			}				

			greenDot.backgroundColor = [UIColor greenColor];
			greenDot.userInteractionEnabled = NO;
			greenDot.layer.cornerRadius = greenDot.frame.size.height/2;
			[greenDot setHidden:YES];

			[self addSubview:greenDot];
			self.greenDot = greenDot;

			//In some apps the appWindow scene is not automaticaally passed to TheGrid, so we have to manually do it so TheGrid can take hold in the application
			if(!self.windowScene && [[UIApplication sharedApplication] windows].count){
				UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
				self.windowScene = appWindow.windowScene;
			}

			//Prevents camera from flickering when device is locked (http://iphonedevwiki.net/index.php/Updating_extensions_for_iOS_8)
			if ([self respondsToSelector:@selector(_setSecure:)]){ [self _setSecure:YES]; }
		}
		else{
			dispatch_sync(dispatch_get_main_queue(), ^{
				self.backgroundColor = nil;
				self.windowLevel = 2020;
				[self setHidden:NO];
				self.userInteractionEnabled = NO;


				if(!yPos && !xPos){ //default (centered)
					if(noNotch) {
						blueDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)-10,17,5,5)]; 
					} else {
						blueDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)-10,34,5,5)]; 
					}
				}
				if(yPos != 0 && !xPos){ //y change no x
					blueDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)-10,yPos,5,5)]; 
				}
				if(!yPos && xPos != 0){ //x change no y
					if(noNotch) {
						blueDot = [[UIView alloc] initWithFrame:CGRectMake(xPos-10,17,5,5)]; 
					} else {
						blueDot = [[UIView alloc] initWithFrame:CGRectMake(xPos-10,34,5,5)]; 
					}
				}
				if(yPos != 0 && xPos != 0){ //both changed
					blueDot = [[UIView alloc] initWithFrame:CGRectMake(xPos-10,yPos,5,5)]; 
				}

				blueDot.backgroundColor = [UIColor colorWithRed:44.0f/255.0f green:143.0f/255.0f blue:255.0f/255.0f alpha:1.0]; 
				blueDot.userInteractionEnabled = NO;
				blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
				[blueDot setHidden:YES];

				[self addSubview:blueDot];
				self.blueDot = blueDot;


				if(!yPos && !xPos){ //default (centered)
					if(noNotch) {
						orangeDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2),17,5,5)]; 
					} else {
						orangeDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2),34,5,5)]; 
					}
				}
				if(yPos != 0 && !xPos){ //y change no x
					orangeDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2),yPos,5,5)];
				}
				if(!yPos && xPos != 0){ //x change no y
					if(noNotch) {
						orangeDot = [[UIView alloc] initWithFrame:CGRectMake(xPos,17,5,5)];
					} else {
						orangeDot = [[UIView alloc] initWithFrame:CGRectMake(xPos,34,5,5)];
					}
				}
				if(yPos != 0 && xPos != 0){ //both changed
					orangeDot = [[UIView alloc] initWithFrame:CGRectMake(xPos,yPos,5,5)];
				}
				
				orangeDot.backgroundColor = [UIColor orangeColor];
				orangeDot.userInteractionEnabled = NO;
				orangeDot.layer.cornerRadius = orangeDot.frame.size.height/2;
				[orangeDot setHidden:YES];

				[self addSubview:orangeDot];
				self.orangeDot = orangeDot;

					
				if(!yPos && !xPos){ //default (centered)
					if(noNotch) {
						greenDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)+10,17,5,5)]; 
					} else {
						greenDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)+10,34,5,5)]; 
					}
				}
				if(yPos != 0 && !xPos){ //y change no x
					greenDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)+10,yPos,5,5)];
				}
				if(!yPos && xPos != 0){ //x change no y
					if(noNotch) {
						greenDot = [[UIView alloc] initWithFrame:CGRectMake(xPos+10,17,5,5)];
					} else {
						greenDot = [[UIView alloc] initWithFrame:CGRectMake(xPos+10,34,5,5)];
					}
				}
				if(yPos != 0 && xPos != 0){ //both changed
					greenDot = [[UIView alloc] initWithFrame:CGRectMake(xPos+10,yPos,5,5)];
				}				

				greenDot.backgroundColor = [UIColor greenColor];
				greenDot.userInteractionEnabled = NO;
				greenDot.layer.cornerRadius = greenDot.frame.size.height/2;
				[greenDot setHidden:YES];

				[self addSubview:greenDot];
				self.greenDot = greenDot;

				//In some apps the appWindow scene is not automaticaally passed to TheGrid, so we have to manually do it so TheGrid can take hold in the application
				if(!self.windowScene && [[UIApplication sharedApplication] windows].count){
					UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
					self.windowScene = appWindow.windowScene;
				}

				//Prevents camera from flickering when device is locked (http://iphonedevwiki.net/index.php/Updating_extensions_for_iOS_8)
				if ([self respondsToSelector:@selector(_setSecure:)]){ [self _setSecure:YES]; }
			});
		}
	}
	
	return self;
}

//prevents my UIWindow from taking control of the status bar 
-(BOOL)_canAffectStatusBarAppearance{
	return NO;
}

@end



//	PREFERENCES 
static void loadPrefs() {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.lightmann.quorraprefs.plist"];

  if(prefs){
	yPos = ( [prefs valueForKey:@"yPos"] ? [[prefs valueForKey:@"yPos"] integerValue] : 0 );
	xPos = ( [prefs valueForKey:@"xPos"] ? [[prefs valueForKey:@"xPos"] integerValue] : 0 );
  }
}

static void initPrefs() {
  // Copy the default preferences file when the actual preference file doesn't exist
  NSString *path = @"/User/Library/Preferences/me.lightmann.quorraprefs.plist";
  NSString *pathDefault = @"/Library/PreferenceBundles/QuorraPrefs.bundle/defaults.plist";
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if(![fileManager fileExistsAtPath:path]) {
    [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
  }
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("me.lightmann.quorraprefs-updated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	initPrefs();
	loadPrefs();
}
