#import <UIKit/UIKit.h>


//Camera and its mic (direct)
@interface AVCaptureDevice : NSObject 
@property (nonatomic,readonly) NSString * localizedName; 
@end

@interface AVCaptureDeviceInput : AVCaptureDevice 
@property (nonatomic,readonly) AVCaptureDevice * device; 
@end

@interface AVCaptureSession : NSObject
@property (readonly) NSArray * inputs;  //contains AVCaptureDeviceInputs
@end


//Camera and its mic (indirect -- UIRemoteView's etc (ex: iMessage Camera extension))
@interface NSExtension : NSObject
@property (nonatomic,copy) NSString * _localizedName;   
@end


//Microphone (general)
@interface AVAudioSessionDataSourceDescription : NSObject
@end

@interface AVAudioSessionPortDescription : NSObject 
@property (readonly) AVAudioSessionDataSourceDescription * selectedDataSource; 
@property (readonly) NSArray * dataSources; 
@end

@interface AVAudioSessionRouteDescription : NSObject 
@property (readonly) NSArray * inputs;  //contains AVAudioSessionPortDescriptions
@property (readonly) NSArray * outputs;  //contains AVAudioSessionPortDescriptions
@end

@interface AVAudioSession : NSObject
@property (readonly) NSString * category; 
@property (readonly) AVAudioSessionRouteDescription * currentRoute; 
@end


//Dictation (mic)
@interface UIDictationController : NSObject
@end


//Voice Control (mic)
@interface AVVoiceController : NSObject
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
