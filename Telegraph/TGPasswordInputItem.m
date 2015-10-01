#import "TGPasswordInputItem.h"

#import "TGPasswordInputItemView.h"

@implementation TGPasswordInputItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = false;
        self.highlightable = false;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGPasswordInputItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
}

- (void)bindView:(TGPasswordInputItemView *)view
{
    [super bindView:view];
    
    __weak TGPasswordInputItem *weakSelf = self;
    view.passwordChanged = ^(NSString *password)
    {
        __strong TGPasswordInputItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf.password = password;
            if (strongSelf.passwordChanged)
                strongSelf.passwordChanged(password);
        }
    };
    [view setPlaceholder:_placeholder];
    [view setPassword:_password];
}

- (void)makeTextFieldFirstResponder
{
    [((TGPasswordInputItemView *)self.boundView) makeTextFieldFirstResponder];
}

@end
