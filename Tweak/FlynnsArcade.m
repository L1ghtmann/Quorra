#import "FlynnsArcade.h"

@implementation FlynnsArcade

+(instancetype)sharedInstance {
	static dispatch_once_t p = 0;
    __strong static FlynnsArcade* sharedInstance = nil;
    dispatch_once(&p, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(TheGrid *)grid {
	static TheGrid* grid = nil;
	if (!grid) {
		grid = [[TheGrid alloc] init];
	}
	return grid;
}

@end
