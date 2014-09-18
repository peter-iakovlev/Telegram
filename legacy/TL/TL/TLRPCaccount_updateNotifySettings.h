#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputNotifyPeer;
@class TLInputPeerNotifySettings;

@interface TLRPCaccount_updateNotifySettings : TLMetaRpc

@property (nonatomic, retain) TLInputNotifyPeer *peer;
@property (nonatomic, retain) TLInputPeerNotifySettings *settings;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updateNotifySettings$account_updateNotifySettings : TLRPCaccount_updateNotifySettings


@end

