#import "TGAppSessionItem.h"

#import "TGAppSessionItemView.h"

@implementation TGAppSessionItem

- (instancetype)initWithAppSession:(TGAppSession *)appSession removeRequested:(void (^)())removeRequested
{
    self = [super init];
    if (self != nil)
    {
        _appSession = appSession;
        _removeRequested = [removeRequested copy];
        self.selectable = false;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGAppSessionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 75.0f);
}

- (void)bindView:(TGAppSessionItemView *)view
{
    [super bindView:view];
    
    [view setAppSession:_appSession];
    __weak TGAppSessionItem *weakSelf = self;
    view.removeRequested = ^
    {
        __strong TGAppSessionItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_removeRequested)
                strongSelf->_removeRequested();
        }
    };
    view.enableEditing = _removeRequested != nil;
}

@end

