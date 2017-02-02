#import "TGPeerRatingUpdates.h"

@implementation TGPeerRatingUpdates

- (instancetype)initWithPeerId:(int64_t)peerId category:(TGPeerRatingCategory)category timestamps:(NSArray<NSNumber *> *)timestamps {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _category = category;
        _timestamps = timestamps;
    }
    return self;
}

@end
