#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import "TheGrid.h"

@interface FlynnsArcade : NSObject {
    CPDistributedMessagingCenter *_messagingCenter;
}
+(instancetype)sharedInstance;
-(TheGrid *)grid;
-(void)handleActivity:(NSString *)activity ofType:(NSDictionary *)info;
-(void)prepNotif:(NSString *)notif WithInfo:(NSDictionary *)info;
@end

// usage notifs
@interface BBBulletin : NSObject
@property (nonatomic,copy) NSString* sectionID;
@property (nonatomic,copy) NSString* bulletinID;
@property (nonatomic,copy) NSString* recordID;
@property (nonatomic,copy) NSString* publisherBulletinID;
@property (nonatomic,copy) NSString* title;
@property (nonatomic,copy) NSString* message;
@property (nonatomic,retain) NSDate* date;
@property (assign,nonatomic) BOOL clearable;
@property (nonatomic) BOOL showsMessagePreview;
@end

@interface BBServer : NSObject
-(id)initWithQueue:(id)arg1;
-(void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
-(void)dealloc;
-(void)_clearSection:(NSString*)arg1;
@end

// prefs
static BOOL isEnabled3;
static BOOL usageLog2;
static BOOL onlyRecent;
