#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputChannel : NSObject <TLObject>


@end

@interface TLInputChannel$inputChannelEmpty : TLInputChannel


@end

@interface TLInputChannel$inputChannel : TLInputChannel

@property (nonatomic) int32_t channel_id;
@property (nonatomic) int64_t access_hash;

@end

