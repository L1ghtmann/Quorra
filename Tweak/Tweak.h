#import <UIKit/UIKit.h>

// Camera
@interface SBUIFlashlightController : UIViewController
@end

// Mic
@interface SBApplication : NSObject
-(NSString *)displayName;
@end

@interface SpringBoard : UIApplication
-(SBApplication *)_accessibilityFrontMostApplication;
@end

// Phone Calls
@interface TUProxyCall : NSObject
@property (nonatomic,readonly) int status;
@end

@interface SBTelephonyManager : NSObject
@end

// Dictation
@interface UIDictationController : NSObject
@end

// Siri
@interface AFSiriClientStateManager : NSObject
@end

// GPS
@interface CLLocationManager : NSObject
@property (assign,nonatomic) BOOL allowsBackgroundLocationUpdates;
+(instancetype)sharedManager;
@end

// prefs
static BOOL isEnabled;
static BOOL camIndicator;
static BOOL micIndicator;
static BOOL gpsIndicator;
static BOOL usageLog;
