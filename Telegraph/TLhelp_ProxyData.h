#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;

@interface TLhelp_ProxyData : NSObject <TLObject>

@property (nonatomic) int32_t expires;

@end

@interface TLhelp_ProxyData$proxyDataPromo : TLhelp_ProxyData

@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLhelp_ProxyData$proxyDataEmpty : TLhelp_ProxyData


@end
