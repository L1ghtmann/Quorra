#import "Headers.h"
#import "FlynnsArcade.h"

// Lightmann
// Made during COVID-19
// Quorra

%group general
// Initalize FlynnsArcade and TheGrid
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
	%orig;

	[[[FlynnsArcade sharedInstance] grid] gridPowerOn];
}
%end
%end


%group camIndicator   
/* Apple doesn't give direct access to the camera at a low-level and only core frameworks only go as low as buffer allocation (i.e. when data is being saved), 
							which happens too late in the cycle for what we want (when pixel data becomes available) 											*/

// Determine when camera is active by checking availability of the flashlight; if flash isn't available cam is active
%hook SBUIFlashlightController 
-(void)_updateStateWithAvailable:(BOOL)arg1 level:(unsigned long long)arg2 overheated:(BOOL)arg3{
	%orig;

	if(!arg1)
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/camActive"), nil, nil, true);
	
	else if(arg1)
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/camInactive"), nil, nil, true);
}
%end
%end


%group micIndicator 
/* no indicator when recording video to match w iOS 14 where camera indicator takes precedent */

// Determine when mic is active (pure audio recording) -- mediaserverd filter necessary --(https://stackoverflow.com/a/21571219)
%hookf(OSStatus, AudioUnitProcess, AudioUnit unit, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inNumberFrames, AudioBufferList *ioData){
	OSStatus orig = %orig;

        AudioComponentDescription unitDescription = {0};
        AudioComponentGetDescription(AudioComponentInstanceGetComponent(unit), &unitDescription);

        // check for mic input data 
        if(unitDescription.componentSubType == 'agc2'){
            if(inNumberFrames > 0){
				CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micActive"), nil, nil, true);
            }
        }
		    
	return orig;
}

// Determine when mic is inactive (pure audio recording) -- mediaserverd filter necessary
%hookf(OSStatus, AudioUnitReset, AudioUnit inUnit, AudioUnitScope inScope, AudioUnitElement inElement){
	OSStatus orig = %orig;

		AudioComponentDescription unitDescription = {0};
		AudioComponentGetDescription(AudioComponentInstanceGetComponent(inUnit), &unitDescription);

		// post notification only for input audio units in hook above (not just any unit) 
		if(unitDescription.componentSubType == 'agc2'){
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);
		}
                
	return orig;
}

// Phone Call EOL methods
%hook SBTelephonyManager
// Taken from Laoyur's CallKiller (https://github.com/laoyur/CallKiller-iOS/blob/master/callkiller/callkiller.xm)
-(void)callEventHandler:(NSNotification*)arg1{
	%orig;

    if(arg1 && arg1.object){
        TUProxyCall *call = arg1.object;
       
	    /*
            call.status:
            1 - call established
            3 - outgoing connecting
            4 - incoming ringing
            5 - disconnecting
            6 - disconnected
        */

        if(call.status == 5 || call.status == 6){
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);
        }
    }
} 
%end

// Determine when dictation is in use
%hook UIDictationController
-(void)startDictation{
	%orig;

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micActive"), nil, nil, true);
}

-(void)stopDictation{ //normal end
	%orig;
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);
}

-(void)cancelDictation{ //any other type of end 
	%orig;
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);	
}
%end

// Determine when Siri is in use 
%hook AFUISiriSession
-(void)assistantConnectionSpeechRecordingWillBegin:(id)arg1{
	%orig;

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micActive"), nil, nil, true);
}

-(void)assistantConnectionSpeechRecordingDidEnd:(id)arg1{  //normal end 
	%orig;

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);
}

-(void)_discardCurrentSpeechGroup{  //any other type of end
	%orig;

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);
}
%end
%end


%group gpsIndicator
%hook CLLocationManager
/* GPS Indicator will only appear while the location is actively being updated. Occasioanlly, apps will simply grab it and store it (like the Weather app)
   						in which case the indicator will appear briefly before disappearing. This is NORMAL behavior!									   */

-(void)startUpdatingLocation{
	%orig;
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/gpsActive"), nil, nil, true);
}

-(void)stopUpdatingLocation{
	%orig;
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/gpsInactive"), nil, nil, true);
}
%end

//Backup EOL method since sone apps don't call stopUpdatingLocation if the app is exited randomly, for whatever reason (e.g., Camera) 
%hook UIApplication
-(void)_applicationDidEnterBackground{
	%orig;
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/gpsInactive"), nil, nil, true);
}
%end
%end


//	PREFERENCES 
void preferencesChanged(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lightmann.quorraprefs"];
	
	isEnabled = (prefs && [prefs objectForKey:@"isEnabled"] ? [[prefs valueForKey:@"isEnabled"] boolValue] : YES );
	camIndicator = (prefs && [prefs objectForKey:@"camIndicator"] ? [[prefs valueForKey:@"camIndicator"] boolValue] : YES );
	micIndicator = (prefs && [prefs objectForKey:@"micIndicator"] ? [[prefs valueForKey:@"micIndicator"] boolValue] : YES );
	gpsIndicator = (prefs && [prefs objectForKey:@"gpsIndicator"] ? [[prefs valueForKey:@"gpsIndicator"] boolValue] : YES );
}

%ctor{
	if ([[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"] || [[NSProcessInfo processInfo].processName isEqualToString:@"SpringBoard"] || [[NSProcessInfo processInfo].processName isEqualToString:@"mediaserverd"]) {
		
		preferencesChanged();

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)preferencesChanged, CFSTR("me.lightmann.quorraprefs-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

		if(isEnabled){
			%init(general);

			if(camIndicator) 
				%init(camIndicator);

			if(micIndicator) 
				%init(micIndicator); 
		
			if(gpsIndicator)
				%init(gpsIndicator);
		}
	}
}
