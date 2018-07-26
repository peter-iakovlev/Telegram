#import "TGUserInfoTextCollectionItem.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGUserInfoTextCollectionItemView.h"

#import "TGModernTextViewModel.h"
#import "TGReusableLabel.h"

#import "TGPresentation.h"

@interface TGUserInfoTextCollectionItem () {
    TGModernTextViewModel *_textModel;
    CGSize _containerSize;
    UIEdgeInsets _safeAreaInset;
    
}

@end

@implementation TGUserInfoTextCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = false;
        self.transparent = true;
        _title = TGLocalized(@"Profile.BotInfo");
        _text = @"";
        
        [self _updateText];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    bool changed = self.presentation != presentation;
    [super setPresentation:presentation];
    
    if (changed && _textModel != nil)
    {
        [self _updateText];

        CGFloat width = [self maximumWidth];
        [_textModel layoutForContainerSize:CGSizeMake(width, CGFLOAT_MAX)];
    }
}

- (Class)itemViewClass
{
    return [TGUserInfoTextCollectionItemView class];
}

- (void)_updateText {
    NSArray *attributes = @[];
    NSArray *textCheckingResults = [TGMessage textCheckingResultsForText:_text highlightMentionsAndTags:true highlightCommands:false entities:nil];
    if (!_highlightLinks) {
        textCheckingResults = @[];
    }
    NSString *string = _text;
    
    _textModel = [[TGModernTextViewModel alloc] initWithText:string font:TGCoreTextSystemFontOfSize(17.0f)];
    _textModel.underlineAllLinks = self.presentation.pallete.underlineAllIncomingLinks;
    _textModel.layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    _textModel.additionalAttributes = attributes;
    _textModel.textCheckingResults = textCheckingResults;
    _textModel.textColor = self.presentation.pallete.collectionMenuTextColor;
    _textModel.linkColor = self.presentation.pallete.linkColor;
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _containerSize = containerSize;
    _safeAreaInset = safeAreaInset;
    CGFloat width = [self maximumWidth];
    if ([_textModel layoutNeedsUpdatingForContainerSize:CGSizeMake(width, CGFLOAT_MAX)])
        [_textModel layoutForContainerSize:CGSizeMake(width, CGFLOAT_MAX)];
    
    return CGSizeMake(containerSize.width, [TGUserInfoTextCollectionItemView heightForWidth:containerSize.width textModel:_textModel]);
}

- (void)setChecking:(bool)checking {
    _checking = checking;
    self.highlightDisabled = checking;
}

- (void)setIsChecked:(bool)isChecked
{
    _isChecked = isChecked;
    
    if ([self boundView] != nil)
        [(TGUserInfoTextCollectionItemView *)[self boundView] setIsChecked:_isChecked animated:true];
}

- (void)bindView:(TGUserInfoTextCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setTextModel:_textModel];
    [view setChecking:_checking];
    [view setIsChecked:_isChecked animated:false];
    
    __weak TGUserInfoTextCollectionItem *weakSelf = self;
    [view setFollowLink:^(NSString *link) {
        __strong TGUserInfoTextCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_followLink) {
            strongSelf->_followLink(link);
        }
    }];
    [view setHoldLink:^(NSString *link) {
        __strong TGUserInfoTextCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_holdLink) {
            strongSelf->_holdLink(link);
        }
    }];
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self _updateText];
    
    if (self.boundView != nil) {

        [_textModel layoutForContainerSize:CGSizeMake([self maximumWidth], CGFLOAT_MAX)];
        [((TGUserInfoTextCollectionItemView *)self.boundView) setTextModel:_textModel];
    }
}

- (CGFloat)maximumWidth
{
    CGFloat padding = _checking ? 60.0f : 15.0f;
    CGFloat width = _containerSize.width - padding - 10.0f - _safeAreaInset.left - _safeAreaInset.right;
    return width;
}

- (void)unbindView
{
    [((TGUserInfoTextCollectionItemView *)self.boundView) setFollowLink:nil];
    [((TGUserInfoTextCollectionItemView *)self.boundView) setHoldLink:nil];
    
    [super unbindView];
}

- (bool)itemWantsMenu
{
    if (self.boundView != nil) {
        return [((TGUserInfoTextCollectionItemView *)self.boundView) shouldDisplayContextMenu];
    }
    return true;
}

- (bool)itemCanPerformAction:(SEL)action
{
    return action == @selector(copy:);
}

- (void)itemPerformAction:(SEL)action
{
    if (action == @selector(copy:))
    {
        if (_text.length != 0)
            [[UIPasteboard generalPasteboard] setString:_text];
    }
}

@end
