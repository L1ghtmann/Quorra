//
//	FlynnsArcade.x
//	Quorra
//
//	Created by Lightmann during COVID-19
//

#import "FlynnsArcade.h"

extern dispatch_queue_t __BBServerQueue;
static BBServer* bbServer;

@implementation FlynnsArcade

+(instancetype)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static FlynnsArcade* sharedInstance = nil;
	dispatch_once(&p, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

// IPC setup
// Helpful link -- https://iphonedevwiki.net/index.php/RocketBootstrap#CPDistributedMessagingCenter_Example
-(instancetype)init {
	self = [super init];

	if(self){
		_messagingCenter = [%c(CPDistributedMessagingCenter) centerNamed:@"me.lightmann.quorra-portal"];
		rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
		[_messagingCenter runServerOnCurrentThread];

		[_messagingCenter registerForMessageName:@"activity" target:self selector:@selector(handleActivity:ofType:)];
		if(usageLog2) [_messagingCenter registerForMessageName:@"usage" target:self selector:@selector(prepNotif:WithInfo:)];
	}

	return self;
}

// Respond to usage messages and display indicator(s) accordingly
-(void)handleActivity:(NSString *)activity ofType:(NSDictionary *)info {
	// crashes w/o a delay (needs time for indicators (UIViews) to render before setAlpha:) ...
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		NSString *type = info[@"type"];
		TheGrid *theGrid = [self grid];

		[UIView animateWithDuration:0.5 animations:^{
			if([type isEqualToString:@"camActive"]){
				[[theGrid greenDot] setAlpha:1];
			}
			else if([type isEqualToString:@"camInactive"]){
				[[theGrid greenDot] setAlpha:0];
			}
			else if([type isEqualToString:@"micActive"]){
				[[theGrid orangeDot] setAlpha:1];
			}
			else if([type isEqualToString:@"micInactive"]){
				[[theGrid orangeDot] setAlpha:0];
			}
			else if([type isEqualToString:@"gpsActive"]){
				[[theGrid blueDot] setAlpha:1];
			}
			else if([type isEqualToString:@"gpsInactive"]){
				[[theGrid blueDot] setAlpha:0];
			}
		}];
	});
}

// Send usage notification given info from prep
-(void)usageNotif:(NSString *)msg{
	if(onlyRecent) [self clearNotifications];

	BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];
	bulletin.title = @"Quorra";
	bulletin.message = msg;
	bulletin.sectionID = @"com.apple.mobiletimer"; // NOTE: on iOS 12 some bundleIDs won't post notifs to the LS (e.g., com.apple.Preferences)
	bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
	bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
	bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
	bulletin.date = [NSDate new];
	bulletin.clearable = YES;
	bulletin.showsMessagePreview = YES;

	if(bbServer){
		dispatch_sync(__BBServerQueue, ^{
			[bbServer publishBulletin:bulletin destinations:4];
		});
	}
}

// Send usage info over to BBulletin to be posted
-(void)prepNotif:(NSString *)notif WithInfo:(NSDictionary *)info {
	[self usageNotif:[NSString stringWithFormat:@"%@ %@ %@", info[@"type"], @"is in use by:", info[@"process"]]];
}

// modified from Conor's Playing (https://github.com/conorthedev/Playing/)
-(void)clearNotifications {
	if(bbServer) {
		dispatch_sync(__BBServerQueue, ^{
			[bbServer _clearSection:@"com.apple.mobiletimer"]; // reason for the arbitrary bundleid (clock) is because its notifs may be cleared here
		});
	}
}

-(TheGrid *)grid {
	static TheGrid* grid = nil;
	if (!grid) {
		grid = [[TheGrid alloc] init];
	}
	return grid;
}

@end


%group Notifs
%hook BBServer
-(instancetype)initWithQueue:(id)arg1{
	bbServer = %orig;
	return bbServer;
}

-(void)dealloc{
	if(bbServer == self) bbServer = nil;
	%orig;
}
%end
%end


//	PREFERENCES
void morePreferencesChanged(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lightmann.quorraprefs"];
	isEnabled3 = (prefs && [prefs objectForKey:@"isEnabled"] ? [[prefs valueForKey:@"isEnabled"] boolValue] : YES );
	usageLog2 = (prefs && [prefs objectForKey:@"usageLog"] ? [[prefs valueForKey:@"usageLog"] boolValue] : NO );
	onlyRecent = (prefs && [prefs objectForKey:@"onlyRecent"] ? [[prefs valueForKey:@"onlyRecent"] boolValue] : NO );
}

%ctor{
	if ([[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"] || [[NSProcessInfo processInfo].processName isEqualToString:@"SpringBoard"]) {
		morePreferencesChanged();

		if(isEnabled3){
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)morePreferencesChanged, CFSTR("me.lightmann.quorraprefs-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

			if(usageLog2) %init(Notifs);
		}
	}
}
