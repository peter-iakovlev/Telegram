#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLLangPackDifference;

@interface TLRPClangpack_getDifference : TLMetaRpc

@property (nonatomic) int32_t from_version;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPClangpack_getDifference$langpack_getDifference : TLRPClangpack_getDifference


@end

