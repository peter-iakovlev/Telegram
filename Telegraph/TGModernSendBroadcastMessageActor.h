#import "TGModernSendMessageActor.h"

#import "TL/TLMetaScheme.h"

@interface TGModernSendBroadcastMessageActor : TGModernSendMessageActor

- (void)sendBroadcastSuccess:(TLmessages_StatedMessages *)statedMessages;
- (void)sendBroadcastFailed;

@end
