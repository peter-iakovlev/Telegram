#import "TGAuthSessionItem.h"

#import "TGAuthSessionItemView.h"

@implementation TGAuthSessionItem

- (instancetype)initWithAuthSession:(TGAuthSession *)authSession removeRequested:(void (^)())removeRequested
{
    self = [super init];
    if (self != nil)
    {
        _authSession = authSession;
        _removeRequested = [removeRequested copy];
        self.selectable = false;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGAuthSessionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 75.0f);
}

- (void)bindView:(TGAuthSessionItemView *)view
{
    [super bindView:view];
    
    [view setAuthSession:_authSession];
    __weak TGAuthSessionItem *weakSelf = self;
    view.removeRequested = ^
    {
        __strong TGAuthSessionItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_removeRequested)
                strongSelf->_removeRequested();
        }
    };
    view.enableEditing = _removeRequested != nil;
}

@end
