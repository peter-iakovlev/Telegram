/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASActor.h"

#import "TLauth_SentCode.h"

#import "ASWatcher.h"

typedef enum {
    TGSendCodeErrorUnknown = -1,
    TGSendCodeErrorInvalidPhone = -2,
    TGSendCodeErrorFloodWait = -3,
    TGSendCodeErrorNetwork = -4,
    TGSendCodeErrorPhoneFlood = -5
} TGSendCodeError;

@interface TGSendCodeRequestBuilder : ASActor <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (void)sendCodeRequestSuccess:(TLauth_SentCode *)sendCode;
- (void)sendCodeRequestFailed:(TGSendCodeError)errorCode;
- (void)sendCodeRedirect:(NSInteger)datacenterId;

- (void)sendSmsRequestSuccess:(TLauth_SentCode *)sentCode;
- (void)sendSmsRequestFailed:(TGSendCodeError)errorCode;
- (void)sendSmsRedirect:(NSInteger)datacenterId;

- (void)sendCallRequestSuccess;
- (void)sendCallRequestFailed;
- (void)sendCallRedirect:(NSInteger)datacenterId;

@end
