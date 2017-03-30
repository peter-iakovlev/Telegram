#import "TGCreditCardNumberCollectionItem.h"

#import "TGCreditCardNumberCollectionItemView.h"

@implementation TGCreditCardNumberCollectionItem

- (Class)itemViewClass {
    return [TGCreditCardNumberCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize {
    return CGSizeMake(containerSize.width, 44.0f);
}

- (void)bindView:(TGCreditCardNumberCollectionItemView *)view {
    [super bindView:view];
    
    __weak TGCreditCardNumberCollectionItem *weakSelf = self;
    view.cardChanged = ^(STPCardParams *params) {
        __strong TGCreditCardNumberCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_cardChanged) {
            strongSelf->_cardChanged(params);
        }
    };
    view.nextField = ^{
        __strong TGCreditCardNumberCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_nextField) {
            strongSelf->_nextField();
        }
    };
}

- (void)unbindView {
    ((TGCreditCardNumberCollectionItemView *)self.boundView).cardChanged = nil;
    ((TGCreditCardNumberCollectionItemView *)self.boundView).nextField = nil;
    
    [super unbindView];
}

- (void)becomeFirstResponder {
    [((TGCreditCardNumberCollectionItemView *)self.boundView) focusInput];
}

@end
