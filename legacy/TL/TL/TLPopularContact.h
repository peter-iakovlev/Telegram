#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPopularContact : NSObject <TLObject>

@property (nonatomic) int64_t client_id;
@property (nonatomic) int32_t importers;

@end

@interface TLPopularContact$popularContact : TLPopularContact


@end

