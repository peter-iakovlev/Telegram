/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASActor.h"

#import "TL/TLMetaScheme.h"

#import "ASWatcher.h"

typedef enum {
    TGSignInResultInvalidToken = -1,
    TGSignInResultNetworkError = -2,
    TGSignInResultTokenExpired = -3,
    TGSignInResultNotRegistered = -4,
    TGSignInResultFloodWait = -5,
    TGSignInResultPasswordRequired = -6
} TGSignInResult;

@interface TGSignInRequestBuilder : ASActor <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

+ (NSString *)genericPath;

- (void)signInSuccess:(TLauth_Authorization *)authorization;
- (void)signInFailed:(TGSignInResult)reason;
- (void)signInRedirect:(NSInteger)datacenterId;

@end
