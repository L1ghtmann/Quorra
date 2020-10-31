#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>

//Camera 
@interface SBUIFlashlightController : UIViewController
@end

//Dictation (mic)
@interface UIDictationController : NSObject
@end

//Siri (mic)
@interface AFUISiriSession : NSObject
@end

//prefs
static BOOL isEnabled;

static BOOL gpsIndicator;
static BOOL micIndicator;
static BOOL camIndicator;
