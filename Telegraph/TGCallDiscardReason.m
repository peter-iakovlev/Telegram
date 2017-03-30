#import "TGCallDiscardReason.h"

@implementation TGCallDiscardReasonAdapter

+ (TGCallDiscardReason)reasonForTLObject:(TLPhoneCallDiscardReason *)object
{
    if ([object isKindOfClass:[TLPhoneCallDiscardReason$phoneCallDiscardReasonMissed class]])
        return TGCallDiscardReasonMissed;
    else if ([object isKindOfClass:[TLPhoneCallDiscardReason$phoneCallDiscardReasonDisconnect class]])
        return TGCallDiscardReasonDisconnect;
    else if ([object isKindOfClass:[TLPhoneCallDiscardReason$phoneCallDiscardReasonHangup class]])
        return TGCallDiscardReasonRemoteHangup;
    else if ([object isKindOfClass:[TLPhoneCallDiscardReason$phoneCallDiscardReasonBusy class]])
        return TGCallDiscardReasonBusy;

    return TGCallDiscardReasonUnknown;
}

+ (TLPhoneCallDiscardReason *)TLObjectForReason:(TGCallDiscardReason)reason
{
    switch (reason) {
        case TGCallDiscardReasonMissed:
        case TGCallDiscardReasonMissedTimeout:
            return [[TLPhoneCallDiscardReason$phoneCallDiscardReasonMissed alloc] init];
            
        case TGCallDiscardReasonDisconnect:
            return [[TLPhoneCallDiscardReason$phoneCallDiscardReasonDisconnect alloc] init];
            
        case TGCallDiscardReasonHangup:
        case TGCallDiscardReasonRemoteHangup:
            return [[TLPhoneCallDiscardReason$phoneCallDiscardReasonHangup alloc] init];
            
        case TGCallDiscardReasonBusy:
            return [[TLPhoneCallDiscardReason$phoneCallDiscardReasonBusy alloc] init];
            
        default:
            return nil;
    }
}

@end
