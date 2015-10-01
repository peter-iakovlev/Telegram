#import "TGCollectionMultilineInputItem.h"

#import "TGCollectionMultilineInputItemView.h"

@interface TGCollectionMultilineInputItem () {
    CGFloat _currentContainerWidth;
}

@end

@implementation TGCollectionMultilineInputItem

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.selectable = false;
        self.editable = true;
    }
    return self;
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize {
    _currentContainerWidth = containerSize.width;
    CGFloat textHeight = [TGCollectionMultilineInputItemView heightForText:_text width:containerSize.width];
    return CGSizeMake(containerSize.width, textHeight);
}

- (Class)itemViewClass {
    return [TGCollectionMultilineInputItemView class];
}

- (void)bindView:(TGCollectionMultilineInputItemView *)view {
    [super bindView:view];
    
    view.placeholder = _placeholder;
    view.text = _text;
    view.editable = _editable;
    view.maxLength = _maxLength;
    __weak TGCollectionMultilineInputItem *weakSelf = self;
    view.textChanged = ^(NSString *text) {
        __strong TGCollectionMultilineInputItem *strongSelf = weakSelf;
        if (strongSelf != nil) {
            CGFloat previousHeight = [TGCollectionMultilineInputItemView heightForText:strongSelf->_text width:strongSelf->_currentContainerWidth];
            strongSelf->_text = text;
            if (strongSelf->_textChanged) {
                strongSelf->_textChanged(text);
            }
            CGFloat currentHeight = [TGCollectionMultilineInputItemView heightForText:strongSelf->_text width:strongSelf->_currentContainerWidth];
            if (ABS(currentHeight - previousHeight) > FLT_EPSILON) {
                if (strongSelf->_heightChanged) {
                    strongSelf->_heightChanged();
                }
            }
        }
    };
}

- (void)unbindView {
    ((TGCollectionMultilineInputItemView *)self.boundView).textChanged = nil;
    
    [super unbindView];
}

- (void)setEditable:(bool)editable {
    _editable = editable;
    
    [(TGCollectionMultilineInputItemView *)[self boundView] setEditable:editable];
    
    self.selectable = !editable;
}

- (bool)itemWantsMenu {
    return !_editable;
}

- (bool)itemCanPerformAction:(SEL)action {
    if (!_editable) {
        return action == @selector(copy:);
    }
    
    return false;
}
- (void)itemPerformAction:(SEL)action {
    if (action == @selector(copy:)) {
        [[UIPasteboard generalPasteboard] setString:_text];
    }
}

@end
