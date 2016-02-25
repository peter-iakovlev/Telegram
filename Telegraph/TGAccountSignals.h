#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGReportPeerReasonSpam,
    TGReportPeerReasonViolence,
    TGReportPeerReasonPornography,
    TGReportPeerReasonOther
} TGReportPeerReason;

@interface TGAccountSignals : NSObject

+ (SSignal *)deleteAccount;
+ (SSignal *)reportPeer:(int64_t)peerId accessHash:(int64_t)accessHash reason:(TGReportPeerReason)reason otherText:(NSString *)otherText;
+ (SSignal *)termsOfService;

@end
