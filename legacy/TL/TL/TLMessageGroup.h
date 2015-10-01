#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLMessageGroup : NSObject <TLObject>

@property (nonatomic) int32_t min_id;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t count;
@property (nonatomic) int32_t date;

@end

@interface TLMessageGroup$messageGroup : TLMessageGroup


@end

