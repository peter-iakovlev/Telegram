#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPhoneConnection : NSObject <TLObject>


@end

@interface TLPhoneConnection$phoneConnectionNotReady : TLPhoneConnection


@end

@interface TLPhoneConnection$phoneConnection : TLPhoneConnection

@property (nonatomic) int64_t n_id;
@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSString *ipv6;
@property (nonatomic) int32_t port;
@property (nonatomic, retain) NSData *peer_tag;

@end

