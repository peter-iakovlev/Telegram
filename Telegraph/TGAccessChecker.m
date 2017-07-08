#import "TGAccessChecker.h"

#import <CoreLocation/CoreLocation.h>
#import "TGSynchronizeContactsActor.h"
#import "TGMediaAssetsLibrary.h"
#import "PGCamera.h"

#import "TGAccessRequiredAlertView.h"

@implementation TGAccessChecker

+ (bool)checkAddressBookAuthorizationStatusWithAlertDismissComlpetion:(void (^)(void))alertDismissCompletion
{
    if ([TGSynchronizeContactsManager instance].phonebookAccessStatus == TGPhonebookAccessStatusDisabled)
    {
        [[[TGAccessRequiredAlertView alloc] initWithMessage:TGLocalized(@"AccessDenied.Contacts")
                                         showSettingsButton:true
                                            completionBlock:alertDismissCompletion] show];
        return false;
    }
    
    return true;
}

+ (bool)checkPhotoAuthorizationStatusForIntent:(TGPhotoAccessIntent)intent alertDismissCompletion:(void (^)(void))alertDismissCompletion
{
    switch ([TGMediaAssetsLibrary authorizationStatus])
    {
        case TGMediaLibraryAuthorizationStatusDenied:
        {
            NSString *message = @"";
            switch (intent)
            {
                case TGPhotoAccessIntentRead:
                    message = TGLocalized(@"AccessDenied.PhotosAndVideos");
                    break;
                    
                case TGPhotoAccessIntentSave:
                    message = TGLocalized(@"AccessDenied.SaveMedia");
                    break;
                    
                case TGPhotoAccessIntentCustomWallpaper:
                    message = TGLocalized(@"AccessDenied.CustomWallpaper");
                    break;
                    
                default:
                    break;
            }
            
            [[[TGAccessRequiredAlertView alloc] initWithMessage:message
                                             showSettingsButton:true
                                                completionBlock:alertDismissCompletion] show];
        }
            return false;
            
        case TGMediaLibraryAuthorizationStatusRestricted:
        {
            [[[TGAccessRequiredAlertView alloc] initWithMessage:TGLocalized(@"AccessDenied.PhotosRestricted")
                                             showSettingsButton:false
                                                completionBlock:alertDismissCompletion] show];
        }
            return false;
            
        default:
            return true;
    }
}

+ (bool)checkMicrophoneAuthorizationStatusForIntent:(TGMicrophoneAccessIntent)intent alertDismissCompletion:(void (^)(void))alertDismissCompletion
{
    switch ([PGCamera microphoneAuthorizationStatus])
    {
        case PGMicrophoneAuthorizationStatusDenied:
        {
            NSString *message = nil;
            switch (intent)
            {
                case TGMicrophoneAccessIntentVoice:
                    message = TGLocalized(@"AccessDenied.VoiceMicrophone");
                    break;
                    
                case TGMicrophoneAccessIntentVideo:
                    message = TGLocalized(@"AccessDenied.VideoMicrophone");
                    break;
                    
                case TGMicrophoneAccessIntentCall:
                    message = TGLocalized(@"AccessDenied.CallMicrophone");
                    break;
                    
                case TGMicrophoneAccessIntentVideoMessage:
                    message = TGLocalized(@"AccessDenied.VideoMessageMicrophone");
                    break;
            }
            
            [[[TGAccessRequiredAlertView alloc] initWithMessage:message
                                             showSettingsButton:true
                                                completionBlock:alertDismissCompletion] show];
        }
            return false;
            
        case PGMicrophoneAuthorizationStatusRestricted:
        {
            [[[TGAccessRequiredAlertView alloc] initWithMessage:TGLocalized(@"AccessDenied.MicrophoneRestricted")
                                             showSettingsButton:false
                                                completionBlock:alertDismissCompletion] show];
        }
            return false;
            
        default:
            return true;
    }
}

+ (bool)checkCameraAuthorizationStatusForIntent:(TGCameraAccessIntent)intent alertDismissCompletion:(void (^)(void))alertDismissCompletion
{
#if TARGET_IPHONE_SIMULATOR
    if (true) {
        return true;
    }
#endif
    
    if (![PGCamera cameraAvailable])
    {
        [[[TGAccessRequiredAlertView alloc] initWithMessage:TGLocalized(@"AccessDenied.CameraDisabled")
                                         showSettingsButton:true
                                            completionBlock:alertDismissCompletion] show];
        
        return false;
    }
    
    switch ([PGCamera cameraAuthorizationStatus])
    {
        case PGCameraAuthorizationStatusDenied:
        {
            NSString *message = nil;
            switch (intent)
            {
                case TGCameraAccessIntentDefault:
                    message = TGLocalized(@"AccessDenied.Camera");
                    break;
                    
                case TGCameraAccessIntentVideoMessage:
                    message = TGLocalized(@"AccessDenied.VideoMessageCamera");
                    break;
            }
            
            [[[TGAccessRequiredAlertView alloc] initWithMessage:message
                                             showSettingsButton:true
                                                completionBlock:alertDismissCompletion] show];
        }
            return false;
            
        case PGCameraAuthorizationStatusRestricted:
        {
            [[[TGAccessRequiredAlertView alloc] initWithMessage:TGLocalized(@"AccessDenied.CameraRestricted")
                                             showSettingsButton:false
                                                completionBlock:alertDismissCompletion] show];
        }
            return false;
            
        default:
            return true;
    }
}

+ (bool)checkLocationAuthorizationStatusForIntent:(TGLocationAccessIntent)intent alertDismissComlpetion:(void (^)(void))alertDismissCompletion
{
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusDenied:
        {
            [[[TGAccessRequiredAlertView alloc] initWithMessage:intent == TGLocationAccessIntentSend ? TGLocalized(@"AccessDenied.LocationDenied") : TGLocalized(@"AccessDenied.LocationTracking")
                                             showSettingsButton:true
                                                completionBlock:alertDismissCompletion] show];
        }
            return false;
            
        case kCLAuthorizationStatusRestricted:
        {
            [[[TGAccessRequiredAlertView alloc] initWithMessage:TGLocalized(@"AccessDenied.LocationDisabled")
                                             showSettingsButton:false
                                                completionBlock:alertDismissCompletion] show];
        }
            return false;

        default:
            return true;
    }
}

@end
