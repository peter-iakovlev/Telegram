#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInvokeAfterMsg : NSObject <TLObject>

@property (nonatomic) int64_t msg_id;
@property (nonatomic) id<NSObject> query;

@end

@interface TLInvokeAfterMsg$invokeAfterMsg : TLInvokeAfterMsg


@end

