#import "TGCollectionStaticMultilineTextItem.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernTextViewModel.h"
#import "TGReusableLabel.h"

#import "TGCollectionStaticMultilineTextItemView.h"

#import "TGPresentation.h"

@interface TGCollectionStaticMultilineTextItem () {
    TGModernTextViewModel *_textModel;
    CGSize _containerSize;
}

@end

@implementation TGCollectionStaticMultilineTextItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = false;
        _text = @"";
        
        [self _updateText];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    if (_textModel != nil)
        [self _updateText];
}

- (Class)itemViewClass
{
    return [TGCollectionStaticMultilineTextItemView class];
}

- (void)_updateText {
    NSArray *attributes = @[];
    NSArray *textCheckingResults = [TGMessage textCheckingResultsForText:_text highlightMentionsAndTags:true highlightCommands:false entities:nil];
    NSString *string = _text;
    
    _textModel = [[TGModernTextViewModel alloc] initWithText:string font:TGCoreTextSystemFontOfSize(16.0f)];
    _textModel.underlineAllLinks = self.presentation.pallete.underlineAllIncomingLinks;
    _textModel.layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    _textModel.additionalAttributes = attributes;
    _textModel.textCheckingResults = textCheckingResults;
    _textModel.textColor = self.presentation.pallete.collectionMenuTextColor;
    _textModel.linkColor = self.presentation.pallete.linkColor;
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    _containerSize = containerSize;
    if ([_textModel layoutNeedsUpdatingForContainerSize:CGSizeMake(containerSize.width - 30.0f, CGFLOAT_MAX)])
        [_textModel layoutForContainerSize:CGSizeMake(containerSize.width - 30.0f, CGFLOAT_MAX)];
    
    return CGSizeMake(containerSize.width, [TGCollectionStaticMultilineTextItemView heightForWidth:containerSize.width textModel:_textModel]);
}

- (void)bindView:(TGCollectionStaticMultilineTextItemView *)view
{
    [super bindView:view];
    
    [view setTextModel:_textModel];
    
    __weak TGCollectionStaticMultilineTextItem *weakSelf = self;
    [view setFollowLink:^(NSString *link) {
        __strong TGCollectionStaticMultilineTextItem *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_followLink) {
            strongSelf->_followLink(link);
        }
    }];
    [view setHoldLink:^(NSString *link) {
        __strong TGCollectionStaticMultilineTextItem *strongSelf = weakSelf;
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
        [_textModel layoutForContainerSize:CGSizeMake(_containerSize.width - 15.0f - 10.0f, CGFLOAT_MAX)];
        [((TGCollectionStaticMultilineTextItemView *)self.boundView) setTextModel:_textModel];
    }
}

- (void)unbindView
{
    [((TGCollectionStaticMultilineTextItemView *)self.boundView) setFollowLink:nil];
    [((TGCollectionStaticMultilineTextItemView *)self.boundView) setHoldLink:nil];
    
    [super unbindView];
}

- (bool)itemWantsMenu
{
    if (self.boundView != nil) {
        return [((TGCollectionStaticMultilineTextItemView *)self.boundView) shouldDisplayContextMenu];
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
