#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLProtoMessage : NSObject <TLObject>

@property (nonatomic) int64_t msg_id;
@property (nonatomic) int32_t seqno;
@property (nonatomic) int32_t bytes;
@property (nonatomic) id<NSObject> body;

@end

@interface TLProtoMessage$protoMessage : TLProtoMessage


@end

