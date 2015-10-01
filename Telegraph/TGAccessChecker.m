#import "TGAccessChecker.h"

#import "TGAccessRequiredAlertView.h"

#import <CoreLocation/CoreLocation.h>
#import "TGSynchronizeContactsActor.h"
#import "TGMediaPickerAssetsLibrary.h"
#import "PGCamera.h"

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
    switch ([[TGMediaPickerAssetsLibrary sharedLibrary] authorizationStatus])
    {
        case TGMediaPickerAuthorizationStatusDenied:
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
            
        case TGMediaPickerAuthorizationStatusRestricted:
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
            [[[TGAccessRequiredAlertView alloc] initWithMessage:intent == TGMicrophoneAccessIntentVoice ? TGLocalized(@"AccessDenied.VoiceMicrophone") : TGLocalized(@"AccessDenied.VideoMicrophone")
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

+ (bool)checkCameraAuthorizationStatusWithAlertDismissComlpetion:(void (^)(void))alertDismissCompletion
{
#if TARGET_IPHONE_SIMULATOR
    return true;
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
            [[[TGAccessRequiredAlertView alloc] initWithMessage:TGLocalized(@"AccessDenied.Camera")
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
