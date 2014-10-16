#import "TGFutureAction.h"

#define TGUpdatePeerLayerFutureActionType ((int)0x50636FAE)

@interface TGUpdatePeerLayerFutureAction : TGFutureAction

@property (nonatomic, readonly) int64_t messageRandomId;

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId messageRandomId:(int64_t)messageRandomId;

@end
