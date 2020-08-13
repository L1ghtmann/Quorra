#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h> 

//Camera (indirect -- UIRemoteView's etc (ex: iMessage Camera extension))
@interface NSExtension : NSObject
@property (nonatomic,copy) NSString * _localizedName;   
@end

//Dictation (mic)
@interface UIDictationController : NSObject
@end

//Siri (mic)
@interface AFUISiriSession : NSObject
@end

//Gps
@interface CLLocation : NSObject
@property (copy,readonly) NSString * description; 
@end

@interface CLLocationManager : NSObject
@property (nonatomic,copy,readonly) CLLocation * location; 
@end

//prefs
static BOOL isEnabled;

static BOOL gpsIndicator;
static BOOL micIndicator;
static BOOL camIndicator;
