#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGReportPeerReasonSpam,
    TGReportPeerReasonViolence,
    TGReportPeerReasonPornography,
    TGReportPeerReasonOther
} TGReportPeerReason;

#import "TGConfirmationCodeData.h"

@interface TGAccountSignals : NSObject

+ (SSignal *)deleteAccount;
+ (SSignal *)reportPeer:(int64_t)peerId accessHash:(int64_t)accessHash reason:(TGReportPeerReason)reason otherText:(NSString *)otherText;
+ (SSignal *)updatedShouldReportSpamForPeer:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)dismissReportSpamForPeer:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)termsOfService;
+ (SSignal *)updateAbout:(NSString *)about;
+ (SSignal *)requestConfirmationForPhoneWithHash:(NSString *)phoneHash;
+ (SSignal *)confirmPhoneWithHash:(NSString *)codeHash code:(NSString *)code;
+ (SSignal *)resendCodeWithHash:(NSString *)codeHash;
+ (SSignal *)registerDeviceToken:(NSString *)deviceToken voip:(bool)voip;
+ (SSignal *)unregisterDeviceToken:(NSString *)deviceToken voip:(bool)voip;

+ (SSignal *)fetchBackupIps:(bool)isTestingEnvironment;

@end
