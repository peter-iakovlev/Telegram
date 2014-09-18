#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputGeoChat : NSObject <TLObject>

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputGeoChat$inputGeoChat : TLInputGeoChat


@end

