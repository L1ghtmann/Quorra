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
		container.rootViewController = ((FlynnsArcade*)[[FlynnsArcade class] sharedInstance]);
	}
	return container;
}

-(void)initiateGrid{
	if(self.gpsIsActive){
		[[self container].blueDot setHidden:NO];
	}
	if(!self.gpsIsActive){
		[[self container].blueDot setHidden:YES];
	}
	if(self.micIsActive){
		[[self container].orangeDot setHidden:NO];
	}
	if(!self.micIsActive){
		[[self container].orangeDot setHidden:YES];
	}
	if(self.cameraIsActive){
		[[self container].greenDot setHidden:NO];
	}
	if(!self.cameraIsActive){
		[[self container].greenDot setHidden:YES];
	}
}

//since we need it to inherit from UIViewController in order to be a rootvc for TheGrid it now has a "view" which we don't need or want
-(void)setView:(id)arg1{
	arg1 = nil;
}

@end