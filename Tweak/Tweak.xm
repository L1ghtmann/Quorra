//Lightmann
//Made during COVID-19
//Quorra

#import "Headers.h"
#import "FlynnsArcade.h"

%group camIndicator   
/* Apple doesn't give direct access to the camera at a low-level and only core methods I could find were for buffer allocation (i.e. when data is being saved), which happens too late in the cycle for what we want (when pixel data becomes available) */

// determine when camera is active by checking availability of the flashlight; if flash isn't available cam is active
%hook SBUIFlashlightController 
-(void)_updateStateWithAvailable:(BOOL)arg1 level:(unsigned long long)arg2 overheated:(BOOL)arg3 {
	%orig;

	if(!arg1){
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
	else if (arg1){
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
	else{
		%orig;
	}
}
%end
%end


%group micIndicator 
/* may eventually add check for phone calls too since that's the only other edge case not currently accounted for.
   no indicator when recording video to match w iOS 14 where camera indicator takes precedent 					  */

//determine when mic is active (pure audio recording)
%hookf(OSStatus, AudioUnitInitialize, AudioUnit inUnit){
	OSStatus orig = %orig;

	if([NSThread isMainThread]){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
	else{
		//dispatch_sync causes some apps to crash or stall and prevents rejailbreaking the device, so using dispatch_async instead (https://iphonemano.blogspot.com/2015/06/dispatchasync-vs-dispatchsync.html)
		dispatch_async(dispatch_get_main_queue(), ^{ 
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
	}

    return orig;
}

//determine when mic is inactive (pure audio recording)
%hookf(OSStatus, AudioUnitUninitialize, AudioUnit inUnit){
	OSStatus orig = %orig;

	if([NSThread isMainThread]){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
	else{
		//dispatch_sync causes some apps to crash or stall and prevents rejailbreaking the device, so using dispatch_async instead (https://iphonemano.blogspot.com/2015/06/dispatchasync-vs-dispatchsync.html)
		dispatch_async(dispatch_get_main_queue(), ^{ 
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
	}

    return orig;
}

//Determine when dictation is in use
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

//Determine when Siri is in use 
%hook AFUISiriSession
-(void)assistantConnectionSpeechRecordingWillBegin:(id)arg1 {
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

-(void)assistantConnectionSpeechRecordingDidEnd:(id)arg1 {
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
/* Quorra now checks for when the device's location is actively being updated, not if it has been or is stored, like previous builds did. 
   A CLLocation can be stored (i.e. updated once and then stored -- like w the weather) or it can be updated constantly (like w the compass) */

//Determine when location is being pulled (i.e. gps in use) 
%hook CLLocationManagerStateTracker
-(void)setUpdatingLocation:(BOOL)arg1 {
	%orig;

	if([NSThread isMainThread]){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).gpsIsActive = arg1;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
	else{
		//dispatch_sync stalls maps, so using dispatch_async instead (https://iphonemano.blogspot.com/2015/06/dispatchasync-vs-dispatchsync.html)
		dispatch_async(dispatch_get_main_queue(), ^{ 
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).gpsIsActive = arg1;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
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
		if(gpsIndicator)
			%init(gpsIndicator)
		
		if(micIndicator)
			%init(micIndicator)

		if(camIndicator)
			%init(camIndicator)
	}
}
