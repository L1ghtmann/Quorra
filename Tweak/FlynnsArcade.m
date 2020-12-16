#import "FlynnsArcade.h"

@implementation FlynnsArcade

+(FlynnsArcade*)sharedInstance {
	static dispatch_once_t p = 0;
    __strong static FlynnsArcade* sharedObject = nil;
    dispatch_once(&p, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

-(TheGrid*)grid {
	static TheGrid* grid = nil;
	if (!grid) {
		grid = [[TheGrid alloc] init];
	}
	return grid;
}

@end
