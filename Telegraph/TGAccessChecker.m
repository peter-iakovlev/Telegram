#import "TGAccessChecker.h"

#import <LegacyComponents/LegacyComponents.h>

#import <CoreLocation/CoreLocation.h>
#import "TGSynchronizeContactsActor.h"
#import <LegacyComponents/TGMediaAssetsLibrary.h>
#import <LegacyComponents/PGCamera.h>

#import "TGAccessRequiredAlertView.h"

@implementation TGAccessChecker

- (bool)checkAddressBookAuthorizationStatusWithAlertDismissComlpetion:(void (^)(void))alertDismissCompletion
{
    if ([TGSynchronizeContactsManager instance].phonebookAccessStatus == TGPhonebookAccessStatusDisabled)
    {
        [TGAccessRequiredAlertView presentWithMessage:TGLocalized(@"AccessDenied.Contacts")
                                         showSettingsButton:true
                                            completionBlock:alertDismissCompletion];
        return false;
    }
    
    return true;
}

- (bool)checkPhotoAuthorizationStatusForIntent:(TGPhotoAccessIntent)intent alertDismissCompletion:(void (^)(void))alertDismissCompletion
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
            
            [TGAccessRequiredAlertView presentWithMessage:message
                                             showSettingsButton:true
                                                completionBlock:alertDismissCompletion];
        }
            return false;
            
        case TGMediaLibraryAuthorizationStatusRestricted:
        {
            [TGAccessRequiredAlertView presentWithMessage:TGLocalized(@"AccessDenied.PhotosRestricted")
                                             showSettingsButton:false
                                                completionBlock:alertDismissCompletion];
        }
            return false;
            
        default:
            return true;
    }
}

- (bool)checkMicrophoneAuthorizationStatusForIntent:(TGMicrophoneAccessIntent)intent alertDismissCompletion:(void (^)(void))alertDismissCompletion
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
            
            [TGAccessRequiredAlertView presentWithMessage:message
                                             showSettingsButton:true
                                                completionBlock:alertDismissCompletion];
        }
            return false;
            
        case PGMicrophoneAuthorizationStatusRestricted:
        {
            [TGAccessRequiredAlertView presentWithMessage:TGLocalized(@"AccessDenied.MicrophoneRestricted")
                                             showSettingsButton:false
                                                completionBlock:alertDismissCompletion];
        }
            return false;
            
        default:
            return true;
    }
}

- (bool)checkCameraAuthorizationStatusForIntent:(TGCameraAccessIntent)intent alertDismissCompletion:(void (^)(void))alertDismissCompletion
{
#if TARGET_IPHONE_SIMULATOR
    if (true) {
        return true;
    }
#endif
    
    if (![PGCamera cameraAvailable])
    {
        [TGAccessRequiredAlertView presentWithMessage:TGLocalized(@"AccessDenied.CameraDisabled")
                                         showSettingsButton:true
                                            completionBlock:alertDismissCompletion];
        
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
            
            [TGAccessRequiredAlertView presentWithMessage:message
                                             showSettingsButton:true
                                                completionBlock:alertDismissCompletion];
        }
            return false;
            
        case PGCameraAuthorizationStatusRestricted:
        {
            [TGAccessRequiredAlertView presentWithMessage:TGLocalized(@"AccessDenied.CameraRestricted")
                                             showSettingsButton:false
                                                completionBlock:alertDismissCompletion];
        }
            return false;
            
        default:
            return true;
    }
}

- (bool)checkLocationAuthorizationStatusForIntent:(TGLocationAccessIntent)intent alertDismissComlpetion:(void (^)(void))alertDismissCompletion
{
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusDenied:
        {
            NSString *message = nil;
            switch (intent)
            {
                case TGLocationAccessIntentSend:
                    message = TGLocalized(@"AccessDenied.LocationDenied");
                    break;
                    
                case TGLocationAccessIntentTracking:
                    message = TGLocalized(@"AccessDenied.LocationTracking");
                    break;
                    
                case TGLocationAccessIntentLiveLocation:
                    message = TGLocalized(@"AccessDenied.LocationAlwaysDenied");
                    break;
            }
            [TGAccessRequiredAlertView presentWithMessage:message
                                             showSettingsButton:true
                                                completionBlock:alertDismissCompletion];
        }
            return false;
            
        case kCLAuthorizationStatusRestricted:
        {
            [TGAccessRequiredAlertView presentWithMessage:TGLocalized(@"AccessDenied.LocationDisabled")
                                             showSettingsButton:false
                                                completionBlock:alertDismissCompletion];
        }
            return false;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            if (intent == TGLocationAccessIntentLiveLocation)
            {
                [TGAccessRequiredAlertView presentWithMessage:TGLocalized(@"AccessDenied.LocationAlwaysDenied")
                                                 showSettingsButton:true
                                                    completionBlock:alertDismissCompletion];
                return false;
            }
        }
            return true;

        default:
            return true;
    }
}

@end
