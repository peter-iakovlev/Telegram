#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputNotifyPeer;
@class TLPeerNotifySettings;

@interface TLRPCaccount_getNotifySettings : TLMetaRpc

@property (nonatomic, retain) TLInputNotifyPeer *peer;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getNotifySettings$account_getNotifySettings : TLRPCaccount_getNotifySettings


@end

