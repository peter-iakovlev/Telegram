#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLMaskCoords : NSObject <TLObject>

@property (nonatomic) int32_t n;
@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double zoom;

@end

@interface TLMaskCoords$maskCoords : TLMaskCoords


@end

