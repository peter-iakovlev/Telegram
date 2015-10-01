#import "TGActor.h"

#import "TL/TLMetaScheme.h"

@interface TGUpdateMediaHistoryActor : TGActor

- (void)mediaHistoryRequestSuccess:(TLmessages_Messages *)messages;
- (void)mediaHistoryRequestFailed;

@end
