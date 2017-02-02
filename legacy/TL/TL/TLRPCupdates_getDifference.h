#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLupdates_Difference;

@interface TLRPCupdates_getDifference : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t qts;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupdates_getDifference$updates_getDifference : TLRPCupdates_getDifference


@end

