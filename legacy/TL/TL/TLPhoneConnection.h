#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPhoneConnection : NSObject <TLObject>


@end

@interface TLPhoneConnection$phoneConnectionNotReady : TLPhoneConnection


@end

@interface TLPhoneConnection$phoneConnection : TLPhoneConnection

@property (nonatomic, retain) NSString *server;
@property (nonatomic) int32_t port;
@property (nonatomic) int64_t stream_id;

@end

