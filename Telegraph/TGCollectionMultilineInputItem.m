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
    
    CGFloat width = _currentContainerWidth;
    if (_showRemainingCount)
        width -= 30.0f;
    
    width -= _insets.left + _insets.right;
    
    CGFloat textHeight = [TGCollectionMultilineInputItemView heightForText:_text width:width];
    if (_minHeight > FLT_EPSILON)
        textHeight = MAX(_minHeight, textHeight);
    return CGSizeMake(containerSize.width, textHeight);
}

- (Class)itemViewClass {
    return [TGCollectionMultilineInputItemView class];
}

- (void)bindView:(TGCollectionMultilineInputItemView *)view {
    [super bindView:view];
    
    view.placeholder = _placeholder;
    view.insets = _insets;
    view.text = _text;
    view.editable = _editable;
    view.maxLength = _maxLength;
    view.disallowNewLines = _disallowNewLines;
    view.showRemainingCount = _showRemainingCount;
    [view setReturnKeyType:_returnKeyType];
    __weak TGCollectionMultilineInputItem *weakSelf = self;
    view.textChanged = ^(NSString *text) {
        __strong TGCollectionMultilineInputItem *strongSelf = weakSelf;
        if (strongSelf != nil) {
            CGFloat width = strongSelf->_currentContainerWidth;
            if (strongSelf->_showRemainingCount)
                width -= 30.0f;
            
            CGFloat previousHeight = [TGCollectionMultilineInputItemView heightForText:strongSelf->_text width:width];
            strongSelf->_text = text;
            if (strongSelf->_textChanged) {
                strongSelf->_textChanged(text);
            }
            CGFloat currentHeight = [TGCollectionMultilineInputItemView heightForText:strongSelf->_text width:width];
            if (ABS(currentHeight - previousHeight) > FLT_EPSILON) {
                if (strongSelf->_heightChanged) {
                    strongSelf->_heightChanged();
                }
            }
        }
    };
    view.returned = ^{
        __strong TGCollectionMultilineInputItem *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf->_returned)
                strongSelf->_returned();
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

- (void)setText:(NSString *)text {
    _text = text;
    ((TGCollectionMultilineInputItemView *)self.boundView).text = text;
}

- (void)setDisallowNewLines:(bool)disallowNewLines
{
    _disallowNewLines = disallowNewLines;
    [(TGCollectionMultilineInputItemView *)self.boundView setDisallowNewLines:disallowNewLines];
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    _returnKeyType = returnKeyType;
    [(TGCollectionMultilineInputItemView *)self.boundView setReturnKeyType:returnKeyType];
}

- (void)setShowRemainingCount:(bool)showRemainingCount
{
    _showRemainingCount = showRemainingCount;
    [(TGCollectionMultilineInputItemView *)self.boundView setShowRemainingCount:showRemainingCount];
}

- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    ((TGCollectionMultilineInputItemView *)self.boundView).insets = insets;
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

- (void)itemSelected:(id)__unused actionTarget
{
    if (_selected) {
        _selected();
    }
}

- (void)becomeFirstResponder {
    [(TGCollectionMultilineInputItemView *)[self boundView] becomeFirstResponder];
}

@end
