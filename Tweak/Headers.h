#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>

//Camera 
@interface SBUIFlashlightController : UIViewController
@end

//Phone Calls 
@interface SBTelephonyManager : NSObject 
@end

@interface TUProxyCall : NSObject
@property (nonatomic,readonly) int status; 
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
