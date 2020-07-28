#import "TheGrid.h"

#define kWidth [UIScreen mainScreen].bounds.size.width 
#define kHeight [UIScreen mainScreen].bounds.size.height
#define noNotch (kHeight < 812)

@implementation TheGrid

- (TheGrid *)init {
	self = [super init];
	
	if (self) {
		self.backgroundColor = nil;
		self.windowLevel = 2020;
		[self setHidden:NO];
        self.userInteractionEnabled = NO;

		UIView *greenDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)-10,34,5,5)];
		if(noNotch) {	greenDot.frame = CGRectMake(greenDot.frame.origin.x,17,greenDot.frame.size.width,greenDot.frame.size.height); }
		greenDot.backgroundColor = [UIColor greenColor];
		greenDot.userInteractionEnabled = NO;
		greenDot.layer.cornerRadius = greenDot.frame.size.height/2;
		[greenDot setHidden:YES];

		[self addSubview:greenDot];
		self.greenDot = greenDot;


		UIView *yellowDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2),34,5,5)];
		if(noNotch) {	yellowDot.frame = CGRectMake(yellowDot.frame.origin.x,17,yellowDot.frame.size.width,yellowDot.frame.size.height); }
		yellowDot.backgroundColor = [UIColor yellowColor];
		yellowDot.userInteractionEnabled = NO;
		yellowDot.layer.cornerRadius = yellowDot.frame.size.height/2;
		[yellowDot setHidden:YES];

		[self addSubview:yellowDot];
		self.yellowDot = yellowDot;


		UIView *redDot = [[UIView alloc] initWithFrame:CGRectMake((kWidth/2)+10,34,5,5)];
		if(noNotch) {	redDot.frame = CGRectMake(redDot.frame.origin.x,17,redDot.frame.size.width,redDot.frame.size.height); }
		redDot.backgroundColor = [UIColor redColor];
		redDot.userInteractionEnabled = NO;
		redDot.layer.cornerRadius = redDot.frame.size.height/2;
		[redDot setHidden:YES];

		[self addSubview:redDot];
		self.redDot = redDot;
	}
	
	return self;
}

@end