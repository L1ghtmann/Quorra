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

// IPC setup 
-(instancetype)init {
	self = [super init];

	if(self){
		_center = [MRYIPCCenter centerNamed:@"me.lightmann.quorra-portal"];
		[_center addTarget:self action:@selector(handleActivity:)];

		if(usageLog2) [_center addTarget:self action:@selector(prepNotifWithInfo:)];
	}
	
	return self;
}

// Respond to usage messages and display indicator(s) accordingly
-(void)handleActivity:(NSDictionary *)args {
	//crashes w/o a delay (needs time for indicators (UIViews) to render before setAlpha:) ...
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		NSString *activity = args[@"activity"];
		TheGrid *theGrid = [self grid];

		[UIView animateWithDuration:0.5 animations:^{
			if([activity isEqualToString:@"camActive"]){
				[[theGrid greenDot] setAlpha:1];
			}
			else if([activity isEqualToString:@"camInactive"]){
				[[theGrid greenDot] setAlpha:0];
			}
			else if([activity isEqualToString:@"micActive"]){
				[[theGrid orangeDot] setAlpha:1];
			}
			else if([activity isEqualToString:@"micInactive"]){
				[[theGrid orangeDot] setAlpha:0];
			}
			else if([activity isEqualToString:@"gpsActive"]){
				[[theGrid blueDot] setAlpha:1];
			}
			else if([activity isEqualToString:@"gpsInactive"]){
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
	bulletin.sectionID = @"com.apple.Preferences";
	bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
	bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
	bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
	bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:@"com.apple.Preferences" callblock:nil];
	bulletin.date = [NSDate new];
	bulletin.clearable = YES;
	bulletin.showsMessagePreview = YES;

	if([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]){
		dispatch_sync(__BBServerQueue, ^{
			[bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
		});
	} 
	else if([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]){
        dispatch_sync(__BBServerQueue, ^{
	    	[bbServer publishBulletin:bulletin destinations:4];
        });
    }
}

// Send usage info over to BBulletin to be posted 
-(void)prepNotifWithInfo:(NSDictionary *)info {
	[self usageNotif:[NSString stringWithFormat:@"%@ %@ %@", info[@"type"], @"is in use by:", info[@"process"]]];
}

//taken from Conor's Playing (https://github.com/conorthedev/Playing/blob/02071b3fcb7bdeec8bcc86e77169b3a65bdcee16/libplaying/PlayingNotificationManager.m)
-(void)clearNotifications {
    dispatch_sync(__BBServerQueue, ^{
        if(bbServer != NULL) {
            NSString *bundleID = @"com.apple.Preferences";
            [bbServer _clearSection:bundleID];
        }
	});
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
- (id)initWithQueue:(id)arg1{
    bbServer = %orig;
    return bbServer;
}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9{
    bbServer = %orig;
    return bbServer;
}

- (void)dealloc{
    if(bbServer == self) bbServer = nil;
    %orig;
}
%end
%end


//	PREFERENCES 
void morePreferencesChanged(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lightmann.quorraprefs"];
	
	usageLog2 = (prefs && [prefs objectForKey:@"usageLog"] ? [[prefs valueForKey:@"usageLog"] boolValue] : NO ); 
	onlyRecent = (prefs && [prefs objectForKey:@"onlyRecent"] ? [[prefs valueForKey:@"onlyRecent"] boolValue] : NO );
}

%ctor{
	if ([[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"] || [[NSProcessInfo processInfo].processName isEqualToString:@"SpringBoard"] || [[NSProcessInfo processInfo].processName isEqualToString:@"mediaserverd"]) {
		morePreferencesChanged();

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)morePreferencesChanged, CFSTR("me.lightmann.quorraprefs-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
				
		if(usageLog2) %init(Notifs);
	}
}
