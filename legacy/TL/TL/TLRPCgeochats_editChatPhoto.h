#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoChat;
@class TLInputChatPhoto;
@class TLgeochats_StatedMessage;

@interface TLRPCgeochats_editChatPhoto : TLMetaRpc

@property (nonatomic, retain) TLInputGeoChat *peer;
@property (nonatomic, retain) TLInputChatPhoto *photo;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_editChatPhoto$geochats_editChatPhoto : TLRPCgeochats_editChatPhoto


@end

