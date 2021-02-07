#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>

//Camera 
@interface SBUIFlashlightController : UIViewController
@end

//Phone Calls 
@interface TUProxyCall : NSObject
@property (nonatomic,readonly) int status; 
@end

@interface SBTelephonyManager : NSObject 
@end

//Dictation 
@interface UIDictationController : NSObject
@end

//Siri 
@interface AFSiriClientStateManager : NSObject
@end

//prefs
static BOOL isEnabled;

static BOOL camIndicator;
static BOOL micIndicator;
static BOOL gpsIndicator;
static BOOL usageLog;  
