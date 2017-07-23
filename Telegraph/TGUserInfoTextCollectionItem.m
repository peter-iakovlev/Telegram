#import "TGUserInfoTextCollectionItem.h"

#import "TGUserInfoTextCollectionItemView.h"

#import "TGModernTextViewModel.h"
#import "TGMessage.h"
#import "TGFont.h"
#import "TGReusableLabel.h"

@interface TGUserInfoTextCollectionItem () {
    TGModernTextViewModel *_textModel;
    CGSize _containerSize;
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
    _textModel.layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    _textModel.additionalAttributes = attributes;
    _textModel.textCheckingResults = textCheckingResults;
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    _containerSize = containerSize;
    if ([_textModel layoutNeedsUpdatingForContainerSize:CGSizeMake(containerSize.width - 35.0f - 10.0f, CGFLOAT_MAX)])
        [_textModel layoutForContainerSize:CGSizeMake(containerSize.width - 35.0f - 10.0f, CGFLOAT_MAX)];
    
    return CGSizeMake(containerSize.width, [TGUserInfoTextCollectionItemView heightForWidth:containerSize.width textModel:_textModel]);
}

- (void)bindView:(TGUserInfoTextCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setTextModel:_textModel];
    
    __weak TGUserInfoTextCollectionItem *weakSelf = self;
    [view setFollowLink:^(NSString *link) {
        __strong TGUserInfoTextCollectionItem *strongSelf = weakSelf;
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
        [_textModel layoutForContainerSize:CGSizeMake(_containerSize.width - 35.0f - 10.0f, CGFLOAT_MAX)];
        [((TGUserInfoTextCollectionItemView *)self.boundView) setTextModel:_textModel];
    }
}

- (void)unbindView
{
    [((TGUserInfoTextCollectionItemView *)self.boundView) setFollowLink:nil];
    
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
