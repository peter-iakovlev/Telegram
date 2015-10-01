#import "TGHolderSet.h"

@interface TGHolder ()

@end

@implementation TGHolder

@end

@interface TGHolderSet ()
{
    NSMutableArray *_holders;
}

@end

@implementation TGHolderSet

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _holders = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addHolder:(TGHolder *)holder
{
    TGDispatchOnMainThread(^
    {
        bool wasEmpty = _holders.count == 0;
        if (![_holders containsObject:holder])
            [_holders addObject:holder];
        
        if (wasEmpty && _emptyStateChanged)
            _emptyStateChanged(true);
    });
}

- (void)removeHolder:(TGHolder *)holder
{
    TGDispatchOnMainThread(^
    {
        bool becameEmpty = false;
        if ([_holders containsObject:holder])
        {
            [_holders removeObject:holder];
            becameEmpty = _holders.count == 0;
        }
        
        if (becameEmpty && _emptyStateChanged)
            _emptyStateChanged(false);
    });
}

@end
