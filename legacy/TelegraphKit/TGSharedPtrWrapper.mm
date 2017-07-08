#import "TGSharedPtrWrapper.h"

@implementation TGSharedPtrWrapper
{
    std::shared_ptr<void> _ptr;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
    }
    return self;
}

- (void)dealloc
{
    _ptr.reset();
}

- (void)setPtr:(std::shared_ptr<void> const &)ptr
{
    _ptr = ptr;
}

- (std::shared_ptr<void> const &)ptr
{
    return _ptr;
}

@end
