#import "TheGrid.h"
#import <MRYIPCCenter.h>

@interface FlynnsArcade : NSObject {
    MRYIPCCenter *_center;
}
+(instancetype)sharedInstance;
-(TheGrid *)grid;
@end

//usage notifs
@interface BBAction : NSObject
+(id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin : NSObject
@property(nonatomic,copy)NSString* sectionID;
@property(nonatomic,copy)NSString* recordID;
@property(nonatomic,copy)NSString* publisherBulletinID;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* message;
@property(nonatomic,retain)NSDate* date;
@property(assign,nonatomic)BOOL clearable;
@property(nonatomic)BOOL showsMessagePreview;
@property(nonatomic,copy)NSString* bulletinID;
@property(nonatomic,copy)BBAction* defaultAction;
@end

@interface BBServer : NSObject
-(void)publishBulletin:(BBBulletin *)arg1 destinations:(NSUInteger)arg2 alwaysToLockScreen:(BOOL)arg3;
-(void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
-(id)initWithQueue:(id)arg1;
-(id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9;
-(void)dealloc;
-(void)_clearSection:(NSString*)arg1;
@end

extern dispatch_queue_t __BBServerQueue;
static BBServer* bbServer;

//prefs
static BOOL usageLog2;
static BOOL onlyRecent;
