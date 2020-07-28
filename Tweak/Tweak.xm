//Lightmann
//Made during COVID-19
//Quorra

#import "Headers.h"
#import "FlynnsArcade.h"


//Initialize my controller
%hook SpringBoard
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;
	[FlynnsArcade sharedInstance];
}
%end


//Determine when camera (and it's mic) are in use (directly)
%hook AVCaptureSession 
-(void)startRunning{
	%orig;

	for(AVCaptureDeviceInput* input in self.inputs){
        AVCaptureDevice *device = [input device];

		//For some methods (such as this one), my code must be run on the main thread, aka "dispatch_get_main_queue," otherwise the application being used crashes
		//See https://stackoverflow.com/a/15169974 for an explanation as to why that is 
		if([device.localizedName isEqualToString:@"Back Camera"] || [device.localizedName isEqualToString:@"Front Camera"]) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = YES;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
        }
		if([device.localizedName isEqualToString:@"iPhone Microphone"]){
			dispatch_sync(dispatch_get_main_queue(), ^{
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
        }
	}
}

-(void)stopRunning{
	%orig;

	for(AVCaptureDeviceInput* input in self.inputs){
		AVCaptureDevice *device = [input device];

		if([device.localizedName isEqualToString:@"Back Camera"] || [device.localizedName isEqualToString:@"Front Camera"] || [device.localizedName isEqualToString:@"iPhone Microphone"]) {
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
	}
}
%end


//Determine when camera (and its mic) are in use (indirectly) 		
%hook NSExtension
-(void)_safelyBeginUsing:(id)arg1 {
	%orig;

	TheGrid *container = [((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) container];

	if([self._localizedName isEqualToString:@"Camera"]){
		dispatch_sync(dispatch_get_main_queue(), ^{
			if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
				UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
				container.windowScene = appWindow.windowScene;
			}
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = YES;
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
	}
}

-(void)_safelyEndUsing:(id)arg1 {
	%orig;

	if([self._localizedName isEqualToString:@"Camera"]){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
}
%end


//Determine when mic is in use (general)
//Yes, I know this could be done more efficiently by checking some daemon's status, but 1) idk how to do that and 2) this should cover all the bases
%hook AVAudioSession  
-(void)privateUpdateDataSources:(id)arg1 forInput:(BOOL)arg2 { 
	%orig;

	if(([self.category isEqualToString:@"AVAudioSessionCategoryRecord"] || [self.category isEqualToString:@"AVAudioSessionCategoryMultiRoute"] || [self.category isEqualToString:@"AVAudioSessionCategoryPlayAndRecord"]) && ((AVAudioSessionPortDescription*)self.currentRoute.inputs.firstObject).selectedDataSource){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
}

-(void)privateUpdatePromptStyle:(id)arg1 {
	%orig;

	if(!([self.category isEqualToString:@"AVAudioSessionCategoryRecord"] || [self.category isEqualToString:@"AVAudioSessionCategoryMultiRoute"] || [self.category isEqualToString:@"AVAudioSessionCategoryPlayAndRecord"]) && ((AVAudioSessionPortDescription*)self.currentRoute.inputs.firstObject).selectedDataSource){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
}
%end


//Determine when dictation (mic) is in use
%hook UIDictationController
-(void)startDictation{
	%orig;

	TheGrid *container = [((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) container];

	if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
		UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
		container.windowScene = appWindow.windowScene;
	}

	((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
	[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
}

-(void)stopDictation{
	%orig;

	((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
	[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];	
}
%end


//Determine when voice control (mic) is in use
%hook AVVoiceController
-(void)beganRecording:(id)arg1 {
	%orig;

	TheGrid *container = [((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) container];

	if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
		UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
		container.windowScene = appWindow.windowScene;
	}

	((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
	[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
}

-(void)finishedRecording:(id)arg1 {
	%orig;

	//All of the "end voice control" methods require a delay for my code to work. If called too soon, the indicator dot flickers, but isn't hidden as intended
	double delayInSeconds = 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];		
	});
}
%end


//Determine when Siri is in use (assumption is that if siri is running the mic is being used)
%hook AFUISiriSession
-(void)setLocalDataSource:(id)arg1{
	%orig;

	if(arg1){
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
}

-(void)endForReason:(long long)arg1{
	%orig;

	((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
	[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
}
%end


//Determine when gps is in use 	
%hook CLLocationManager 
-(void)onDidBecomeActive:(id)arg1 {
	%orig;

	TheGrid *container = [((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) container];

	if(self.location){
		if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
			UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
			container.windowScene = appWindow.windowScene;
		}
		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).gpsIsActive = YES;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
}
%end
