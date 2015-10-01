#import "TGPhoneCodeCollectionItem.h"

#import "TGPhoneCodeCollectionItemView.h"

@implementation TGPhoneCodeCollectionItem

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
    return [TGPhoneCodeCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 45.0f);
}

- (void)bindView:(TGPhoneCodeCollectionItemView *)view
{
    [super bindView:view];
    
    view.codeChanged = _codeChanged;
}

- (void)unbindView
{
    ((TGPhoneCodeCollectionItemView *)self.boundView).codeChanged = nil;
    
    [super unbindView];
}

- (void)becomeFirstResponder
{
    [((TGPhoneCodeCollectionItemView *)self.boundView) makeCodeFieldFirstResponder];
}

@end
