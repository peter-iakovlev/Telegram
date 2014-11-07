#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInvokeWithLayer : NSObject <TLObject>

@property (nonatomic) int32_t layer;
@property (nonatomic) id<NSObject> query;

@end

@interface TLInvokeWithLayer$invokeWithLayer : TLInvokeWithLayer


@end

