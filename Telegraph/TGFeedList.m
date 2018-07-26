#import "TGFeedList.h"

@interface TGFeedList ()
{
    NSArray *_feeds;
}
@end

@implementation TGFeedList

- (instancetype)initWithFeeds:(NSArray *)feeds
{
    self = [super init];
    if (self != nil)
    {
        _feeds = feeds;
    }
    return self;
}

- (NSArray *)feeds
{
    return _feeds;
}

@end
