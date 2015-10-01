#import "TGCountryAndPhoneCollectionItem.h"

#import "TGCountryAndPhoneCollectionItemView.h"

@implementation TGCountryAndPhoneCollectionItem

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
    return [TGCountryAndPhoneCollectionItemView class];
}

- (void)bindView:(TGCountryAndPhoneCollectionItemView *)view
{
    [super bindView:view];
    
    view.presentViewController = _presentViewController;
    view.phoneChanged = _phoneChanged;
}

- (void)unbindView
{
    ((TGCountryAndPhoneCollectionItemView *)self.boundView).presentViewController = nil;
    ((TGCountryAndPhoneCollectionItemView *)self.boundView).phoneChanged = nil;
    
    [super unbindView];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 88.0f);
}

- (void)becomeFirstResponder
{
    [((TGCountryAndPhoneCollectionItemView *)self.boundView) makeCountryFieldFirstResponder];
}

@end
