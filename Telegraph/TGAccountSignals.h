#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGReportPeerReasonSpam,
    TGReportPeerReasonViolence,
    TGReportPeerReasonPornography,
    TGReportPeerReasonCopyright,
    TGReportPeerReasonOther
} TGReportPeerReason;

#import "TGConfirmationCodeData.h"

@interface TGAccountSignals : NSObject

+ (SSignal *)deleteAccount:(NSString *)reason;
+ (SSignal *)reportPeer:(int64_t)peerId accessHash:(int64_t)accessHash reason:(TGReportPeerReason)reason otherText:(NSString *)otherText;
+ (SSignal *)updatedShouldReportSpamForPeer:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)dismissReportSpamForPeer:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)termsOfServiceUpdate;
+ (SSignal *)acceptTermsOfService:(NSString *)identifier;
+ (SSignal *)updateAbout:(NSString *)about;
+ (SSignal *)requestConfirmationForPhoneWithHash:(NSString *)phoneHash;
+ (SSignal *)confirmPhoneWithHash:(NSString *)codeHash code:(NSString *)code;
+ (SSignal *)resendCodeWithHash:(NSString *)codeHash;
+ (SSignal *)registerDeviceToken:(NSString *)deviceToken voip:(bool)voip;
+ (SSignal *)unregisterDeviceToken:(NSString *)deviceToken voip:(bool)voip;

+ (SSignal *)reportMessages:(int64_t)peerId accessHash:(int64_t)accessHash messageIds:(NSArray *)messageIds reason:(TGReportPeerReason)reason otherText:(NSString *)otherText;

+ (SSignal *)currentContactsJoinedNotificationSettings;
+ (SSignal *)updateContactsJoinedNotificationSettings:(bool)enabled;

@end
