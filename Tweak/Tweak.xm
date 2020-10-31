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
/* may eventually add check for phone calls too since that's the only other edge case not currently accounted for */
/* no indicator when recording video to match w iOS 14 where camera indicator takes precedent */

//determine when mic is active (pure audio recording)
%hookf(OSStatus, AudioUnitInitialize, AudioUnit inUnit){
	OSStatus orig = %orig;

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
		dispatch_sync(dispatch_get_main_queue(), ^{
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
	}

    return orig;
}

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
//Determine when device location is being accessed (i.e. gps in use) 	
%hook CLLocationManager 
// covers most apps
-(void)setDelegate:(id)arg1 {
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

//covers the edge cases like Maps that doesn't use a delegate
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
		if(gpsIndicator)
			%init(gpsIndicator)
		
		if(micIndicator)
			%init(micIndicator)

		if(camIndicator)
			%init(camIndicator)
	}
}
