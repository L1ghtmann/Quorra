#import "Headers.h"
#import "FlynnsArcade.h"

// Lightmann
// Made during COVID-19
// Quorra

%group General
// Initialize FlynnsArcade and TheGrid
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
	%orig;

	[[[FlynnsArcade sharedInstance] grid] gridPowerOn];
}
%end
%end


%group Camera
// Determine when camera is active by checking availability of the flashlight -- if flash isn't available then the cam is active 
// * Won't work for devices w/o a flashlight *
%hook SBUIFlashlightController 
-(void)_updateStateWithAvailable:(BOOL)arg1 level:(unsigned long long)arg2 overheated:(BOOL)arg3{
	%orig;

	if(!arg1){
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/camActive"), nil, nil, true);
	}
	else if(arg1){
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/camInactive"), nil, nil, true);
	}
}
%end
%end


%group Microphone 
// Determine when mic is active (*mediaserverd filter necessary)
// The implementation in these AudioUnit hooks is far from perfect: 
// As a result of the conditions checked, the mic indicator may be present or missing when it shouldn't be (ex: missing in iMessage and Discord)
// The conditions checked in said hooks prevent the mic indicator from displaying for phone calls, dictation, and siri, so those each get their own hooks  
%hookf(OSStatus, AudioUnitInitialize, AudioUnit inUnit){
	OSStatus orig = %orig;

		AudioComponentDescription desc = {0};
		AudioComponentGetDescription(AudioComponentInstanceGetComponent(inUnit), &desc);
		
		//description of a component prepping for mic input 
		if(desc.componentType == kAudioUnitType_Output && desc.componentSubType == kAudioUnitSubType_RemoteIO && desc.componentFlags == 0 && desc.componentFlagsMask == 0){
		    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micActive"), nil, nil, true);
		}

	return orig;
}

// Determine when mic is inactive (*mediaserverd filter necessary)
%hookf(OSStatus, AudioUnitUninitialize, AudioUnit inUnit){
	OSStatus orig = %orig;

		AudioComponentDescription desc = {0};
		AudioComponentGetDescription(AudioComponentInstanceGetComponent(inUnit), &desc);

		//matching description to unit(s) monitored above 
		if(desc.componentType == kAudioUnitType_Output && desc.componentSubType == kAudioUnitSubType_RemoteIO && desc.componentFlags == 0 && desc.componentFlagsMask == 0){
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);
		}
                
	return orig;
}

// Determine when a call is active -- taken from Laoyur's CallKiller (https://github.com/laoyur/CallKiller-iOS/blob/master/callkiller/callkiller.xm)
%hook SBTelephonyManager
-(void)callEventHandler:(NSNotification*)arg1{
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

		if(call.status == 1){
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micActive"), nil, nil, true);
		}
        else if(call.status == 6){
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);
        }
    }
	%orig;
} 
%end

// Determine when dictation is active
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

// Determine when Siri is active
%hook AFSiriClientStateManager 
-(void)beginListeningForClient:(void*)arg1 {
	%orig;

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micActive"), nil, nil, true);
}

-(void)endListeningForClient:(void*)arg1 {
	%orig;

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/micInactive"), nil, nil, true);
}
%end
%end


%group GPS
%hook CLLocationManager
// GPS Indicator will only appear while the location is actively being updated. 
// Occasioanlly, apps will grab it and store it (like the Weather app) in which case the indicator will appear briefly before disappearing. 
// This is NORMAL behavior!								    
-(void)startUpdatingLocation{
	%orig;
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/gpsActive"), nil, nil, true);
}

-(void)stopUpdatingLocation{
	%orig;
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.lightmann.quorra/gpsInactive"), nil, nil, true);
}
%end

//Backup EOL method -- Ideally wouldn't need this, but some apps don't call stopUpdatingLocation if closed abruptly (e.g., Camera) 
%hook UIApplication
-(void)applicationWillSuspend{
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
			%init(General);

			if(camIndicator) %init(Camera);

			if(micIndicator) %init(Microphone);

			if(gpsIndicator) %init(GPS);
		}
	}
}
