#import "FlynnsArcade.h"

@implementation FlynnsArcade

+ (FlynnsArcade*)sharedInstance {
	static dispatch_once_t p = 0;
    __strong static FlynnsArcade* sharedObject = nil;
    dispatch_once(&p, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (TheGrid*)container {
	static TheGrid* container = nil;
	if (!container) {
		container = [[TheGrid alloc] init];
	}
	return container;
}

-(void)initiateGrid{
	if(self.gpsIsActive){
		[[self container].greenDot setHidden:NO];
	}
	if(!self.gpsIsActive){
		[[self container].greenDot setHidden:YES];
	}
	if(self.micIsActive){
		[[self container].yellowDot setHidden:NO];
	}
	if(!self.micIsActive){
		[[self container].yellowDot setHidden:YES];
	}
	if(self.cameraIsActive){
		[[self container].redDot setHidden:NO];
	}
	if(!self.cameraIsActive){
		[[self container].redDot setHidden:YES];
	}
}

@end