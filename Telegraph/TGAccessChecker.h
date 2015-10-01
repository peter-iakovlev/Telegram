#import <Foundation/Foundation.h>

typedef enum {
    TGPhotoAccessIntentRead,
    TGPhotoAccessIntentSave,
    TGPhotoAccessIntentCustomWallpaper
} TGPhotoAccessIntent;

typedef enum {
    TGMicrophoneAccessIntentVoice,
    TGMicrophoneAccessIntentVideo,
} TGMicrophoneAccessIntent;

typedef enum {
    TGLocationAccessIntentSend,
    TGLocationAccessIntentTracking,
} TGLocationAccessIntent;

@interface TGAccessChecker : NSObject

+ (bool)checkAddressBookAuthorizationStatusWithAlertDismissComlpetion:(void (^)(void))alertDismissCompletion;

+ (bool)checkPhotoAuthorizationStatusForIntent:(TGPhotoAccessIntent)intent alertDismissCompletion:(void (^)(void))alertDismissCompletion;

+ (bool)checkMicrophoneAuthorizationStatusForIntent:(TGMicrophoneAccessIntent)intent alertDismissCompletion:(void (^)(void))alertDismissCompletion;

+ (bool)checkCameraAuthorizationStatusWithAlertDismissComlpetion:(void (^)(void))alertDismissCompletion;

+ (bool)checkLocationAuthorizationStatusForIntent:(TGLocationAccessIntent)intent alertDismissComlpetion:(void (^)(void))alertDismissCompletion;

@end
