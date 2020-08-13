//Lightmann
//Made during COVID-19
//Quorra

#import "Headers.h"
#import "FlynnsArcade.h"

%group ungrouped
//Initialize my controller
%hook SpringBoard
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;
	[FlynnsArcade sharedInstance];
}
%end


//Determine when camera (and its mic) are in use (indirectly) 		
%hook NSExtension
-(void)_safelyBeginUsing:(id)arg1 {
	%orig;

	//In every method used here you'll see a check for (if([NSThread isMainThread]){}) and a dispatch to (dispatch_sync(dispatch_get_main_queue(), ^{})) the main thread
	//The reason being many applications crash if we try to make UI changes on the background thread ("threading violation: expected the main thread") . . .
	//or if we dispatch to the main thread when we're already on it (EXC_BREAKPOINT (SIGTRAP))
	//See https://www.quora.com/Why-must-the-UI-always-be-updated-on-Main-Thread for a better explanation as to why that is 

	if(camIndicator || micIndicator){
		if([self._localizedName isEqualToString:@"Camera"]){
			if([NSThread isMainThread]){
				if(camIndicator) ((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = YES;
				if(micIndicator) ((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			}
			else{
				dispatch_sync(dispatch_get_main_queue(), ^{
					if(camIndicator) ((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = YES;
					if(micIndicator) ((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
					[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
				});
			}
		}
	}
}

-(void)_safelyEndUsing:(id)arg1 {
	%orig;

	if(camIndicator || micIndicator){
		if([self._localizedName isEqualToString:@"Camera"]){
			if([NSThread isMainThread]){
				if(camIndicator) ((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
				if(micIndicator) ((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			}
			else{
				dispatch_sync(dispatch_get_main_queue(), ^{
					if(camIndicator) ((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
					if(micIndicator) ((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO; 
					[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
				});
			}
		}
	}
}
%end
%end



%group camIndicator
//Determine when camera (and it's mic) are in use (directly)
%hook AVCaptureDeviceInput
-(void)_sourceFormatDidChange:(id)arg1 {
	%orig;

	if ([self.device hasMediaType:AVMediaTypeVideo] || [self.device hasMediaType:AVMediaTypeMuxed]) {
		if([NSThread isMainThread]){
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
		else{
			dispatch_sync(dispatch_get_main_queue(), ^{
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = YES;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
		}
    }
}

-(void)_resetVideoMinFrameDurationOverride{
	%orig;

	if([NSThread isMainThread]){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
	else{
		dispatch_sync(dispatch_get_main_queue(), ^{
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
	}
}
%end
%end



%group micIndicator
//Determine when mic is in use (general) -- doesn't apply to dictation or siri
%hook SBApplication
-(void)setNowRecordingApplication:(BOOL)arg1 {
	%orig;

	if(arg1){
		if([NSThread isMainThread]){
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
		else{
			dispatch_sync(dispatch_get_main_queue(), ^{
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
		}
	}
	if(!arg1){
		if([NSThread isMainThread]){
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
		else{
			dispatch_sync(dispatch_get_main_queue(), ^{
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
		}	
	}
}
%end


//Determine when dictation is in use (assumption is that if dictation is occurring the mic is being used)
%hook UIDictationController
-(void)startDictation{
	%orig;

	if([NSThread isMainThread]){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
	else{
		dispatch_sync(dispatch_get_main_queue(), ^{
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
	}
}

-(void)stopDictation{
	%orig;
	
	if([NSThread isMainThread]){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];	
	}
	else{
		dispatch_sync(dispatch_get_main_queue(), ^{
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];	
		});
	}
}
%end


//Determine when Siri is in use (assumption is that if siri is running the mic is being used)
%hook AFUISiriSession
-(void)setLocalDataSource:(id)arg1{
	%orig;

	if(arg1){
		if([NSThread isMainThread]){
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
		else{
			dispatch_sync(dispatch_get_main_queue(), ^{
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
		}
	}
}

-(void)endForReason:(long long)arg1{
	%orig;

	if([NSThread isMainThread]){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
	else{
		dispatch_sync(dispatch_get_main_queue(), ^{
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
	}
}
%end
%end



%group gpsIndicator
//Determine when gps is in use 	
%hook CLLocationManager 
-(void)onDidBecomeActive:(id)arg1 {
	%orig;

	if(self.location){
		if([NSThread isMainThread]){
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).gpsIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
		else{
			dispatch_sync(dispatch_get_main_queue(), ^{
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).gpsIsActive = YES;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
		}
	}
}
%end
%end



//	PREFERENCES 
static void loadPrefs() {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.lightmann.quorraprefs.plist"];

  if(prefs){
    isEnabled = ( [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES );
	gpsIndicator = ( [prefs objectForKey:@"gpsIndicator"] ? [[prefs objectForKey:@"gpsIndicator"] boolValue] : YES );
	micIndicator = ( [prefs objectForKey:@"micIndicator"] ? [[prefs objectForKey:@"micIndicator"] boolValue] : YES );
	camIndicator = ( [prefs objectForKey:@"camIndicator"] ? [[prefs objectForKey:@"camIndicator"] boolValue] : YES );
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

	if(isEnabled){
		%init(ungrouped)

		if(gpsIndicator)
			%init(gpsIndicator)
		
		if(micIndicator)
			%init(micIndicator)

		if(camIndicator)
			%init(camIndicator)
	}
}
