#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdates;

@interface TLRPCmessages_createChat : TLMetaRpc

@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSString *title;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_createChat$messages_createChat : TLRPCmessages_createChat


@end

