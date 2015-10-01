#import "TGActor.h"

typedef enum {
    TGCheckPasswordErrorCodeInvalidPassword = -1,
    TGCheckPasswordErrorCodeFlood = -2
} TGCheckPasswordErrorCode;

@interface TGCheckPasswordActor : TGActor

@end
