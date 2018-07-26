#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;

@interface TLFeedPosition : NSObject <TLObject>


@end

@interface TLFeedPosition$feedPosition : TLFeedPosition

@property (nonatomic) int32_t date;
@property (nonatomic, strong) TLPeer *peer;
@property (nonatomic) int32_t n_id;

@end
