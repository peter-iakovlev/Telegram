#import "TGUpdateAppInfoItem.h"
#import "TGUpdateAppInfoItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernTextViewModel.h"
#import "TGReusableLabel.h"

#import "TGPresentation.h"

@interface TGUpdateAppInfoItem ()
{
    TGModernTextViewModel *_textModel;
    CGSize _containerSize;
    UIEdgeInsets _safeAreaInset;
}
@end

@implementation TGUpdateAppInfoItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = false;
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
    return [TGUpdateAppInfoItemView class];
}

- (void)_updateText {
    NSArray *attributes = @[];
    NSArray *textCheckingResults = [TGMessage textCheckingResultsForText:_text highlightMentionsAndTags:true highlightCommands:false entities:_entities];
    NSString *string = _text;
    
    _textModel = [[TGModernTextViewModel alloc] initWithText:string font:TGCoreTextSystemFontOfSize(16.0f)];
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
    
    return CGSizeMake(containerSize.width, 75.0f + [TGUpdateAppInfoItemView heightForWidth:containerSize.width textModel:_textModel]);
}

- (void)bindView:(TGUpdateAppInfoItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setTextModel:_textModel];
    
    __weak TGUpdateAppInfoItem *weakSelf = self;
    [view setFollowLink:^(NSString *link) {
        __strong TGUpdateAppInfoItem *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_followLink) {
            strongSelf->_followLink(link);
        }
    }];
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self _updateText];
    
    if (self.boundView != nil) {
        
        [_textModel layoutForContainerSize:CGSizeMake([self maximumWidth], CGFLOAT_MAX)];
        [((TGUpdateAppInfoItemView *)self.boundView) setTextModel:_textModel];
    }
}

- (void)setEntities:(NSArray *)entities
{
    _entities = entities;
    [self _updateText];
    
    if (self.boundView != nil) {
        [_textModel layoutForContainerSize:CGSizeMake([self maximumWidth], CGFLOAT_MAX)];
        [((TGUpdateAppInfoItemView *)self.boundView) setTextModel:_textModel];
    }
}

- (void)unbindView
{
    [((TGUpdateAppInfoItemView *)self.boundView) setFollowLink:nil];
    
    [super unbindView];
}

- (CGFloat)maximumWidth
{
    CGFloat padding = 10.0f;
    CGFloat width = _containerSize.width - padding - 10.0f - _safeAreaInset.left - _safeAreaInset.right;
    return width;
}

@end
