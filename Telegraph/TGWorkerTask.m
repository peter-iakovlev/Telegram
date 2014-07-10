/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGWorkerTask.h"

@interface TGWorkerTask ()
{
    volatile bool _cancelled;
}

@property (nonatomic, copy) void (^block)(bool (^isCancelled)());

@end

@implementation TGWorkerTask

- (instancetype)initWithBlock:(void (^)(bool (^isCancelled)()))block
{
    self = [super init];
    if (self != nil)
    {
        self.block = block;
    }
    return self;
}

- (void)execute
{
    if (!_cancelled && _block != nil)
    {
        __weak TGWorkerTask *weakSelf = self;
        _block(^bool
        {
            __strong TGWorkerTask *strongSelf = weakSelf;
            return strongSelf == nil || strongSelf->_cancelled;
        });
    }
}

- (void)cancel
{
    _cancelled = true;
}

@end
