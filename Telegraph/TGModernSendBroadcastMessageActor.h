#import "TGModernSendMessageActor.h"

#import "TL/TLMetaScheme.h"

@interface TGModernSendBroadcastMessageActor : TGModernSendMessageActor

- (void)sendBroadcastSuccess:(TLUpdates *)statedMessages;
- (void)sendBroadcastFailed;

@end
