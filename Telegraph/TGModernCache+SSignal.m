#import "TGModernCache+SSignal.h"

@implementation TGModernCache (SSignal)

- (SSignal *)cachedItemForKey:(NSData *)key
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        [self getValueForKey:key completion:^(NSData *data)
        {
            [subscriber putNext:data];
            [subscriber putCompletion];
        }];
        
        return nil;
    }];
}

@end
