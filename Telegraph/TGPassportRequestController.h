#import "TGCollectionMenuController.h"

#import "TGPassportFormRequest.h"

@class TGPasswordSettings;

typedef enum
{
    TGPassportPasswordRequestStateNoPassword,
    TGPassportPasswordRequestStateWaitingEmail,
    TGPassportPasswordRequestStateWaitingForEntry,
    TGPassportPasswordRequestStateLoggingInProgress,
    TGPassportPasswordRequestStateSettingNewPassword,
    TGPassportPasswordRequestStateInvalidSecret,
    TGPassportPasswordRequestStateAccessDenied,
    TGPassportPasswordRequestStateAuthorized
} TGPassportRequestState;

@interface TGPassportPasswordRequest : NSObject

@property (nonatomic, readonly) TGPassportRequestState state;
@property (nonatomic, readonly) TGPasswordSettings *settings;
@property (nonatomic, readonly) bool hasRecovery;
@property (nonatomic, readonly) NSString *passwordHint;
@property (nonatomic, readonly) NSString *error;

+ (instancetype)requestWithState:(TGPassportRequestState)state settings:(TGPasswordSettings *)settings hasRecovery:(bool)hasRecovery passwordHint:(NSString *)passwordHint error:(NSString *)error;

@end

@interface TGPassportRequestController : TGCollectionMenuController

- (instancetype)initWithFormRequest:(TGPassportFormRequest *)formRequest;

+ (NSString *)urlString:(NSString *)urlString byAppendingQueryString:(NSString *)queryString;

@end
