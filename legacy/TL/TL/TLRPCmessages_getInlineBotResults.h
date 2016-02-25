#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLmessages_BotResults;

@interface TLRPCmessages_getInlineBotResults : TLMetaRpc

@property (nonatomic, retain) TLInputUser *bot;
@property (nonatomic, retain) NSString *query;
@property (nonatomic, retain) NSString *offset;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getInlineBotResults$messages_getInlineBotResults : TLRPCmessages_getInlineBotResults


@end

