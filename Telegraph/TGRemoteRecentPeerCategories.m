#import "TGRemoteRecentPeerCategories.h"

@implementation TGRemoteRecentPeerCategories

- (instancetype)initWithLastRefreshTimestamp:(NSTimeInterval)lastRefreshTimestamp categories:(NSDictionary<NSNumber *, TGRemoteRecentPeerSet *> *)categories {
    self = [super init];
    if (self != nil) {
        _lastRefreshTimestamp = lastRefreshTimestamp;
        _categories = categories;
    }
    return self;
}

@end
