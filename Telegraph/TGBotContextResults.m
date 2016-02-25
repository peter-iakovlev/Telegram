#import "TGBotContextResults.h"

@implementation TGBotContextResults

- (instancetype)initWithUserId:(int32_t)userId isMedia:(bool)isMedia query:(NSString *)query nextOffset:(NSString *)nextOffset results:(NSArray *)results {
    self = [super init];
    if (self != nil) {
        _userId = userId;
        _isMedia = isMedia;
        _query = query;
        _nextOffset = nextOffset;
        _results = results;
    }
    return self;
}

@end
