#import "TGActor.h"

typedef enum {
    TGVerifyChangePhoneErrorServer = -1,
    TGVerifyChangePhoneErrorInvalidPhone = -2,
    TGVerifyChangePhoneErrorFlood = -3,
    TGVerifyChangePhoneErrorPhoneOccupied = -4
} TGVerifyChangePhoneError;

@interface TGVerifyChangePhoneActor : TGActor

@end
