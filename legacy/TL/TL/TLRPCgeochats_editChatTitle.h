#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;
@class TLgeochats_StatedMessage;

@interface TLRPCgeochats_editChatTitle : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_editChatTitle$geochats_editChatTitle : TLRPCgeochats_editChatTitle


@end

