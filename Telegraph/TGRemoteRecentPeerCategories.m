#import "TGRemoteRecentPeerCategories.h"

@implementation TGRemoteRecentPeerCategories

- (instancetype)initWithLastRefreshTimestamp:(NSTimeInterval)lastRefreshTimestamp categories:(NSDictionary<NSNumber *, TGRemoteRecentPeerSet *> *)categories disabled:(bool)disabled {
    self = [super init];
    if (self != nil) {
        _lastRefreshTimestamp = lastRefreshTimestamp;
        _categories = categories;
        _disabled = disabled;
    }
    return self;
}

@end
