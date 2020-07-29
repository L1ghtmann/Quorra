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

		//In every method used here you'll see a check for (if([NSThread isMainThread]){}) and a dispatch to (dispatch_sync(dispatch_get_main_queue(), ^{})) the main thread
		//The reason being many applications crash if we try to make UI changes on the background thread ("threading violation: expected the main thread") . . .
		//or if we dispatch to the main thread when we're already on it (EXC_BREAKPOINT (SIGTRAP))
		//See https://www.quora.com/Why-must-the-UI-always-be-updated-on-Main-Thread for a better explanation as to why that is 
		if([device.localizedName isEqualToString:@"Back Camera"] || [device.localizedName isEqualToString:@"Front Camera"]) {
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
		if([device.localizedName isEqualToString:@"iPhone Microphone"]){
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
}

-(void)stopRunning{
	%orig;

	for(AVCaptureDeviceInput* input in self.inputs){
		AVCaptureDevice *device = [input device];

		if([device.localizedName isEqualToString:@"Back Camera"] || [device.localizedName isEqualToString:@"Front Camera"] || [device.localizedName isEqualToString:@"iPhone Microphone"]) {
			if([NSThread isMainThread]){
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			}
			else{
				dispatch_sync(dispatch_get_main_queue(), ^{
					((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
					((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
					[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
				});
			}
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
		if([NSThread isMainThread]){
			if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
				UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
				container.windowScene = appWindow.windowScene;
			}
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = YES;
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
		else{
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
}

-(void)_safelyEndUsing:(id)arg1 {
	%orig;

	if([self._localizedName isEqualToString:@"Camera"]){
		if([NSThread isMainThread]){
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
		else{
			dispatch_sync(dispatch_get_main_queue(), ^{
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).cameraIsActive = NO;
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = NO;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
		}
	}
}
%end


//Determine when mic is in use (general)
//Yes, I know this could be done more efficiently by checking some daemon's status, but 1) idk how to do that and 2) this should cover all the bases
%hook AVAudioSession  
-(void)privateUpdateDataSources:(id)arg1 forInput:(BOOL)arg2 { 
	%orig;

	if(([self.category isEqualToString:@"AVAudioSessionCategoryRecord"] || [self.category isEqualToString:@"AVAudioSessionCategoryMultiRoute"] || [self.category isEqualToString:@"AVAudioSessionCategoryPlayAndRecord"]) && ((AVAudioSessionPortDescription*)self.currentRoute.inputs.firstObject).selectedDataSource){
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

-(void)privateUpdatePromptStyle:(id)arg1 {
	%orig;

	if(!([self.category isEqualToString:@"AVAudioSessionCategoryRecord"] || [self.category isEqualToString:@"AVAudioSessionCategoryMultiRoute"] || [self.category isEqualToString:@"AVAudioSessionCategoryPlayAndRecord"]) && ((AVAudioSessionPortDescription*)self.currentRoute.inputs.firstObject).selectedDataSource){
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


//Determine when dictation (mic) is in use
%hook UIDictationController
-(void)startDictation{
	%orig;

	TheGrid *container = [((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) container];

	if([NSThread isMainThread]){
		if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
			UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
			container.windowScene = appWindow.windowScene;
		}

		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
	else{
		dispatch_sync(dispatch_get_main_queue(), ^{
			if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
				UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
				container.windowScene = appWindow.windowScene;
			}

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


//Determine when voice control (mic) is in use
%hook AVVoiceController
-(void)beganRecording:(id)arg1 {
	%orig;

	TheGrid *container = [((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) container];
	
	if([NSThread isMainThread]){
		if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
			UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
			container.windowScene = appWindow.windowScene;
		}

		((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
		[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
	}
	else{
		dispatch_sync(dispatch_get_main_queue(), ^{
			if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
				UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
				container.windowScene = appWindow.windowScene;
			}

			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).micIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		});
	}
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


//Determine when gps is in use 	
%hook CLLocationManager 
-(void)onDidBecomeActive:(id)arg1 {
	%orig;

	TheGrid *container = [((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) container];

	if(self.location){
		if([NSThread isMainThread]){
			if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
				UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
				container.windowScene = appWindow.windowScene;
			}
			((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).gpsIsActive = YES;
			[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
		}
		else{
			dispatch_sync(dispatch_get_main_queue(), ^{
				if(!container.windowScene && [[UIApplication sharedApplication] windows].count){
					UIWindow *appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 
					container.windowScene = appWindow.windowScene;
				}
				((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]).gpsIsActive = YES;
				[((FlynnsArcade*)[%c(FlynnsArcade) sharedInstance]) initiateGrid];
			});
		}
	}
}
%end
