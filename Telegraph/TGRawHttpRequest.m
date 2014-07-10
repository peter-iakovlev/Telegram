#import "TGRawHttpRequest.h"

@implementation TGRawHttpRequest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _maxRetryCount = 3;
    }
    return self;
}

- (void)cancel
{
    self.cancelled = true;
    if (self.operation != nil)
        [self.operation cancel];
    [self dispose];
}

- (void)dispose
{
    self.url = nil;
    self.operation = nil;
    self.completionBlock = nil;
}

@end
