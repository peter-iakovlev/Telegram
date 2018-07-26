#import "TGGenericPeerMediaGalleryDefaultFooterView.h"

#import <LegacyComponents/LegacyComponents.h>
#import <SafariServices/SafariServices.h>

#import "TGAppDelegate.h"

#import "TGGenericPeerGalleryItem.h"
#import "TGGenericPeerMediaGalleryVideoItem.h"

#import "TGItemCollectionGalleryItem.h"
#import "TGSecretPeerMediaGalleryImageItem.h"
#import "TGSecretPeerMediaGalleryVideoItem.h"
#import "TGUserAvatarGalleryItem.h"
#import "TGGroupAvatarGalleryItem.h"
#import "TGGenericPeerGalleryGroupItem.h"

#import "TGModernFlatteningViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGReusableLabel.h"
#import "TGCollectionStaticMultilineTextItemView.h"

#import "TGCustomActionSheet.h"
#import "TGOpenInMenu.h"

#import "TGGenericPeerMediaGalleryGroupSliderView.h"

const CGPoint TGGenericPeerMediaGalleryDefaultFooterViewCaptionOrigin = { 13.0f, -8.0f };

@interface TGGalleryTextLabelLink : NSObject

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, strong, readonly) NSString *link;
@property (nonatomic, strong) UIButton *button;

@end

@implementation TGGalleryTextLabelLink

- (instancetype)initWithRange:(NSRange)range link:(NSString *)link {
    self = [super init];
    if (self != nil) {
        _range = range;
        _link = link;
    }
    return self;
}

@end

@interface TGGenericPeerMediaGalleryDefaultFooterView ()
{
    bool _hasAppeared;
    UIEdgeInsets _safeAreaInset;
    
    UILabel *_nameLabel;
    UILabel *_dateLabel;
    
    UIView *_captionPanelView;
    TGCollectionStaticMultilineTextItemViewTextView *_captionView;
    TGModernTextViewModel *_textModel;
    
    UIView *_groupPanelView;
    TGGenericPeerMediaGalleryGroupSliderView *_groupSliderView;
    int64_t _currentGroupedId;
    int64_t _currentGroupedKeyId;
    
    UIView *_videoPanelView;
    bool _isVideo;
    
    UIView *_customContentView;
    
    NSMutableDictionary *_captionHeightForWidth;
}
@end

@implementation TGGenericPeerMediaGalleryDefaultFooterView

@dynamic groupItemChanged;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _captionPanelView = [[UIView alloc] initWithFrame:CGRectZero];
        _captionPanelView.backgroundColor = UIColorRGBA(0x000000, 0.65f);
        _captionPanelView.clipsToBounds = true;
        [self addSubview:_captionPanelView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = TGBoldSystemFontOfSize(15.0f);
        [self addSubview:_nameLabel];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_dateLabel];
        
        _captionView = [[TGCollectionStaticMultilineTextItemViewTextView alloc] init];
        _captionView.userInteractionEnabled = true;
        
        __weak TGGenericPeerMediaGalleryDefaultFooterView *weakSelf = self;
        _captionView.followLink = ^(NSString *url)
        {
            __strong TGGenericPeerMediaGalleryDefaultFooterView *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf.openLinkRequested(url);
        };
        _captionView.holdLink = ^(NSString *url)
        {
            __strong TGGenericPeerMediaGalleryDefaultFooterView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf showActionsMenuForLink:url];
        };
        [_captionPanelView addSubview:_captionView];
        
        _groupPanelView = [[UIView alloc] initWithFrame:CGRectZero];
        _groupPanelView.backgroundColor = _captionPanelView.backgroundColor;
        _groupPanelView.clipsToBounds = true;
        [self addSubview:_groupPanelView];
        
        _groupSliderView = [[TGGenericPeerMediaGalleryGroupSliderView alloc] init];
        [_groupPanelView addSubview:_groupSliderView];
        
        _videoPanelView = [[UIView alloc] initWithFrame:CGRectZero];
        _videoPanelView.backgroundColor = _captionPanelView.backgroundColor;
        _videoPanelView.clipsToBounds = true;
        [self addSubview:_videoPanelView];
        
    }
    return self;
}

- (void)setGroupItemChanged:(void (^)(TGGenericPeerGalleryGroupItem *, bool))groupItemChanged
{
    _groupSliderView.itemChanged = groupItemChanged;
}

- (void)setInterItemTransitionProgress:(CGFloat)progress
{
    [_groupSliderView setTransitionProgress:progress];
}

- (void)showActionsMenuForLink:(NSString *)url
{
    if (url.length == 0)
        return;

    UIView *parentView = self.parentController.view;
    if ([url hasPrefix:@"tel:"])
    {
        TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:url.length < 70 ? url : [[url substringToIndex:70] stringByAppendingString:@"..."] actions:@
                                            [
                                             [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.PhoneCall") action:@"call"],
                                             [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"],
                                             [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                                             ] actionBlock:^(__unused TGGenericPeerMediaGalleryDefaultFooterView *controller, NSString *action)
        {
            if ([action isEqualToString:@"call"])
            {
                [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:url]];
            }
            else if ([action isEqualToString:@"copy"])
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (pasteboard != nil)
                {
                    NSString *copyString = url;
                    if ([url hasPrefix:@"mailto:"])
                        copyString = [url substringFromIndex:7];
                    else if ([url hasPrefix:@"tel:"])
                        copyString = [url substringFromIndex:4];
                    [pasteboard setString:copyString];
                }
            }
        } target:self];
        [actionSheet showInView:parentView];
    }
    else
    {
        NSString *displayString = url;
        if ([url hasPrefix:@"hashtag://"])
            displayString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
        else if ([url hasPrefix:@"mention://"])
            displayString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
        
        
        NSURL *link = [NSURL URLWithString:url];
        if (link.scheme.length == 0)
            link = [NSURL URLWithString:[@"http://" stringByAppendingString:url]];
        
        bool useOpenIn = false;
        bool isWeblink = false;
        if ([link.scheme isEqualToString:@"http"] || [link.scheme isEqualToString:@"https"])
        {
            isWeblink = true;
            if ([TGOpenInMenu hasThirdPartyAppsForURL:link])
                useOpenIn = true;
        }
        
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        if (useOpenIn)
        {
            TGActionSheetAction *openInAction = [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.FileOpenIn") action:@"openIn"];
            openInAction.disableAutomaticSheetDismiss = true;
            [actions addObject:openInAction];
        }
        else
        {
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogOpen") action:@"open"]];
        }
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"]];
        
        if (isWeblink && iosMajorVersion() >= 7)
        {
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.AddToReadingList") action:@"addToReadingList"]];
        }
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:displayString.length < 70 ? displayString : [[displayString substringToIndex:70] stringByAppendingString:@"..."] actions:actions menuController:nil advancedActionBlock:^(TGMenuSheetController *menuController, TGGenericPeerMediaGalleryDefaultFooterView *controller, NSString *action)
        {
            if ([action isEqualToString:@"open"])
            {
                if (controller.openLinkRequested != nil)
                    controller.openLinkRequested(url);
            }
            else if ([action isEqualToString:@"openIn"])
            {
                [TGOpenInMenu presentInParentController:controller.parentController menuController:menuController title:TGLocalized(@"Map.OpenIn") url:link buttonTitle:nil buttonAction:nil sourceView:parentView sourceRect:nil barButtonItem:nil];
            }
            else if ([action isEqualToString:@"copy"])
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (pasteboard != nil)
                {
                    NSString *copyString = url;
                    if ([url hasPrefix:@"mailto:"])
                        copyString = [url substringFromIndex:7];
                    else if ([url hasPrefix:@"tel:"])
                        copyString = [url substringFromIndex:4];
                    else if ([url hasPrefix:@"hashtag://"])
                        copyString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
                    else if ([url hasPrefix:@"mention://"])
                        copyString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
                    [pasteboard setString:copyString];
                }
            }
            else if ([action isEqualToString:@"addToReadingList"])
            {
                [[SSReadingList defaultReadingList] addReadingListItemWithURL:[NSURL URLWithString:url] title:url previewText:nil error:NULL];
            }
        } target:self];
        [actionSheet showInView:parentView];
    }
}

- (void)setupCaption:(NSString *)text textCheckingResults:(NSArray *)textCheckingResults
{
    _textModel = [[TGModernTextViewModel alloc] initWithText:text font:TGCoreTextSystemFontOfSize(16.0f)];
    _textModel.textColor = [UIColor whiteColor];
    _textModel.linkColor = [UIColor whiteColor];
    _textModel.textCheckingResults = textCheckingResults;
    _textModel.layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    
    CGFloat parentWidth = self.superview.frame.size.width - _safeAreaInset.left - _safeAreaInset.right;
    [_textModel layoutForContainerSize:CGSizeMake([self captionWidthForWidth:parentWidth], CGFLOAT_MAX)];
    
    [_captionView setTextModel:_textModel];
    [self setNeedsLayout];
}

- (void)setItem:(id<TGModernGalleryItem>)item
{
    if (![item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)] && ![item isKindOfClass:[TGItemCollectionGalleryItem class]] && ![item isKindOfClass:[TGSecretPeerMediaGalleryImageItem class]] && ![item isKindOfClass:[TGSecretPeerMediaGalleryVideoItem class]] && ![item isKindOfClass:[TGUserAvatarGalleryItem class]] && ![item isKindOfClass:[TGGroupAvatarGalleryItem class]])
        return;
    
    bool shouldAnimate = _hasAppeared;

    NSString *newCaption = nil;
    NSArray *newTextCheckingResults = nil;
    NSArray *groupItems = nil;
    int64_t groupedId = 0;
    int64_t groupedKeyId = 0;
    bool isVideo = false;
    if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)]) {
        id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
        NSString *title = nil;
        if ([[concreteItem authorPeer] isKindOfClass:[TGUser class]]) {
            title = ((TGUser *)[concreteItem authorPeer]).displayName;
        } else if ([[concreteItem authorPeer] isKindOfClass:[TGConversation class]]) {
            title = ((TGConversation *)[concreteItem authorPeer]).chatTitle;
        } else if (concreteItem.author.length > 0)
            title = concreteItem.author;
        
        if ([concreteItem respondsToSelector:@selector(caption)])
            newCaption = [concreteItem performSelector:@selector(caption) withObject:nil];
        if ([concreteItem respondsToSelector:@selector(textCheckingResults)])
            newTextCheckingResults = [concreteItem performSelector:@selector(textCheckingResults) withObject:nil];
        
        if ([concreteItem respondsToSelector:@selector(groupItems)])
        {
            if (concreteItem.groupItems.count > 1)
            {
                groupItems = concreteItem.groupItems;
                groupedId = concreteItem.groupedId;
                groupedKeyId = concreteItem.messageId;
            }
            else
            {
                groupItems = nil;
                groupedId = 0;
                groupedKeyId = NSNotFound;
            }
        }
        
        if ([concreteItem isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
            isVideo = true;
        
        _nameLabel.text = title;
        _dateLabel.text = [concreteItem date] > 0 ? [TGDateUtils stringForApproximateDate:(int)[concreteItem date]] : nil;
    } else if ([item isKindOfClass:[TGItemCollectionGalleryItem class]]) {
        TGItemCollectionGalleryItem *concreteItem = (TGItemCollectionGalleryItem *)item;
        newCaption = [concreteItem.media caption];
        
        if (concreteItem.groupItems.count > 1)
        {
            groupItems = concreteItem.groupItems;
            groupedId = concreteItem.groupedId;
            groupedKeyId = concreteItem.index;
        }
        else
        {
            groupItems = nil;
            groupedId = 0;
            groupedKeyId = NSNotFound;
        }
    } else if ([item isKindOfClass:[TGSecretPeerMediaGalleryImageItem class]]) {
        TGSecretPeerMediaGalleryImageItem *concreteItem = (TGSecretPeerMediaGalleryImageItem *)item;
        NSString *title = nil;
        if ([[concreteItem author] isKindOfClass:[TGUser class]]) {
            title = ((TGUser *)[concreteItem author]).displayName;
        } else if ([[concreteItem author] isKindOfClass:[TGConversation class]]) {
            title = ((TGConversation *)[concreteItem author]).chatTitle;
        }
        _nameLabel.text = title;
        _dateLabel.text = [TGDateUtils stringForApproximateDate:(int)[concreteItem date]];
    } else if ([item isKindOfClass:[TGSecretPeerMediaGalleryVideoItem class]]) {
        TGSecretPeerMediaGalleryVideoItem *concreteItem = (TGSecretPeerMediaGalleryVideoItem *)item;
        NSString *title = nil;
        if ([[concreteItem author] isKindOfClass:[TGUser class]]) {
            title = ((TGUser *)[concreteItem author]).displayName;
        } else if ([[concreteItem author] isKindOfClass:[TGConversation class]]) {
            title = ((TGConversation *)[concreteItem author]).chatTitle;
        }
        _nameLabel.text = title;
        _dateLabel.text = [TGDateUtils stringForApproximateDate:(int)[concreteItem date]];
    } else if ([item isKindOfClass:[TGUserAvatarGalleryItem class]]) {
        TGUserAvatarGalleryItem *concreteItem = (TGUserAvatarGalleryItem *)item;
        groupedId = _currentGroupedId;
        groupedKeyId = concreteItem.imageId;
    } else if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]]) {
        TGGroupAvatarGalleryItem *concreteItem = (TGGroupAvatarGalleryItem *)item;
        groupedId = _currentGroupedId;
        groupedKeyId = concreteItem.imageId;
    }
    
    _hasAppeared = true;
    
    if ([_textModel.text isEqualToString:newCaption] && groupedId == _currentGroupedId && _currentGroupedKeyId == groupedKeyId && isVideo == _isVideo)
    {
        [self setNeedsLayout];
        return;
    }

    _captionHeightForWidth = [[NSMutableDictionary alloc] init];
    
    bool groupChanged = _currentGroupedId != groupedId;
    _currentGroupedId = groupedId;
    _currentGroupedKeyId = groupedKeyId;
    
    bool videoChanged = _isVideo != isVideo;
    _isVideo = isVideo;
    
    UIView *captionSnapshotView = nil;
    if (shouldAnimate && !_captionView.hidden)
    {
        captionSnapshotView = [_captionView snapshotViewAfterScreenUpdates:false];
        captionSnapshotView.frame = _captionView.frame;
        [_captionPanelView insertSubview:captionSnapshotView belowSubview:_captionView];
        
        _captionView.alpha = 0.0f;
        _captionView.hidden = true;
    }
    
    [self setupCaption:newCaption textCheckingResults:newTextCheckingResults];
    
    if (!shouldAnimate)
    {
        _captionView.hidden = (_textModel.text.length == 0);
        _captionView.alpha = _captionView.hidden ? 0.0f : 1.0f;
    }
    
    UIView *groupSnapshotView = nil;
    if (shouldAnimate && groupChanged && !_groupSliderView.hidden)
    {
        groupSnapshotView = [_groupSliderView snapshotViewAfterScreenUpdates:false];
        groupSnapshotView.frame = _groupSliderView.frame;
        [_groupPanelView insertSubview:groupSnapshotView belowSubview:_groupSliderView];
        
        _groupSliderView.alpha = 0.0f;
        _groupSliderView.hidden = true;
    }
    
    UIView *videoSnapshotView = nil;
    if (shouldAnimate && videoChanged && _customContentView != nil && !_customContentView.hidden)
    {
        videoSnapshotView = [_customContentView snapshotViewAfterScreenUpdates:false];
        videoSnapshotView.frame = _customContentView.frame;
        [_videoPanelView insertSubview:videoSnapshotView belowSubview:_customContentView];
        
        _customContentView.alpha = 0.0f;
        _customContentView.hidden = true;
    }
    
    if (groupedId != 1)
        [_groupSliderView setGroupedId:groupedId items:groupItems];
    if (groupedId != 0 && groupedKeyId != NSNotFound)
        [_groupSliderView setCurrentItemKey:groupedKeyId animated:false];
    
    if (!shouldAnimate)
    {
        _groupSliderView.hidden = groupedId == 0;
        _groupSliderView.alpha = _groupSliderView.hidden ? 0.0f : 1.0f;
    }
    
    if (!shouldAnimate)
    {
        _customContentView.hidden = !isVideo;
        _customContentView.alpha = _customContentView.hidden ? 0.0f : 1.0f;
    }
    
    CGFloat fadeOutDuration = 0.21f;
    if (shouldAnimate)
    {
        CGFloat parentWidth = self.superview.frame.size.width;
        CGRect captionTargetFrame = [self captionPanelFrameForParentWidth:parentWidth captionHeight:[self captionHeightForWidth:parentWidth] inGroup:_currentGroupedId != 0 isVideo:_isVideo];
        if (captionTargetFrame.size.height < FLT_EPSILON)
            fadeOutDuration = 0.17f;
        
        CGFloat fadeInDelay = 0.08f;
        if (fabs(captionTargetFrame.size.height - _captionPanelView.frame.size.height) > FLT_EPSILON)
        {
            fadeInDelay = 0.11f;
            
            [UIView animateWithDuration:0.3f delay:0.0f options:7 << 16 animations:^
            {
                _captionPanelView.frame = captionTargetFrame;
            } completion:nil];
        }
        
        CGRect groupTargetFrame = [self groupPanelFrameForParentWidth:parentWidth inGroup:_currentGroupedId != 0];
        if (fabs(groupTargetFrame.size.height - _groupPanelView.frame.size.height) > FLT_EPSILON)
        {
            [UIView animateWithDuration:0.3f delay:0.0f options:7 << 16 animations:^
            {
                _groupPanelView.frame = groupTargetFrame;
            } completion:nil];
        }

        CGRect videoTargetFrame = [self videoPanelFrameForParentWidth:parentWidth inGroup:_currentGroupedId != 0 isVideo:_isVideo];
        if (fabs(videoTargetFrame.size.height - _videoPanelView.frame.size.height) > FLT_EPSILON)
        {
            [UIView animateWithDuration:0.3f delay:0.0f options:7 << 16 animations:^
            {
                _videoPanelView.frame = videoTargetFrame;
            } completion:nil];
        }
        
        if (_textModel.text.length > 0)
        {
            _captionView.hidden = false;
            [UIView animateWithDuration:0.24f delay:fadeInDelay options:UIViewAnimationOptionCurveEaseInOut animations:^
            {
                _captionView.alpha = 1.0f;
            } completion:nil];
        }
        
        if (groupedId != 0)
        {
            _groupSliderView.hidden = false;
            [UIView animateWithDuration:0.24f delay:fadeInDelay options:UIViewAnimationOptionCurveEaseInOut animations:^
            {
                _groupSliderView.alpha = 1.0f;
            } completion:nil];
        }
        
        if (isVideo)
        {
            _customContentView.hidden = false;
            [UIView animateWithDuration:0.24f delay:fadeInDelay options:UIViewAnimationOptionCurveEaseInOut animations:^
            {
                _customContentView.alpha = 1.0f;
            } completion:nil];
        }
    }
    
    if (captionSnapshotView != nil)
    {
        [UIView animateWithDuration:fadeOutDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            captionSnapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [captionSnapshotView removeFromSuperview];
        }];
    }
    
    if (groupSnapshotView != nil)
    {
        [UIView animateWithDuration:fadeOutDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            groupSnapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [groupSnapshotView removeFromSuperview];
        }];
    }
    
    if (videoSnapshotView != nil)
    {
        [UIView animateWithDuration:fadeOutDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            videoSnapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [videoSnapshotView removeFromSuperview];
        }];
    }
    
    [self setNeedsLayout];
}

- (void)setGroupItems:(NSArray *)groupItems
{
    _currentGroupedId = 1;
    [_groupSliderView setGroupedId:1 items:groupItems];
    [_groupSliderView setCurrentItemKey:[groupItems.firstObject keyId] animated:false];
}

- (void)setContentHidden:(bool)contentHidden
{
    _nameLabel.hidden = contentHidden;
    _dateLabel.hidden = contentHidden;
}

- (void)setCustomContentView:(UIView *)contentView
{
    if (_customContentView != nil && _customContentView != contentView)
    {
        [_customContentView removeFromSuperview];
        _customContentView = nil;
    }
    
    _customContentView = contentView;
    [_videoPanelView addSubview:_customContentView];
    [self setNeedsLayout];
}

- (CGRect)captionPanelFrameForParentWidth:(CGFloat)width captionHeight:(CGFloat)captionHeight inGroup:(bool)inGroup isVideo:(bool)isVideo
{
    CGFloat panelHeight = captionHeight > FLT_EPSILON ? captionHeight + 17.0f : 0.0f;
    if (isVideo)
        panelHeight -= 5.0f;
    CGFloat y = -panelHeight;
    if (inGroup)
        y -= 43.0f;
    if (isVideo)
        y -= 43.0f;
    return CGRectMake(-self.frame.origin.x, y, width, panelHeight);
}

- (CGRect)groupPanelFrameForParentWidth:(CGFloat)width inGroup:(bool)inGroup
{
    CGFloat panelHeight = inGroup > FLT_EPSILON ? 43.0f : 0.0f;
    return CGRectMake(-self.frame.origin.x, -panelHeight, width, panelHeight);
}

- (CGRect)videoPanelFrameForParentWidth:(CGFloat)width inGroup:(bool)inGroup isVideo:(bool)isVideo
{
    CGFloat panelHeight = isVideo > FLT_EPSILON ? 43.0f : 0.0f;
    CGFloat y = -panelHeight;
    if (inGroup)
        y -= 43.0f;
    return CGRectMake(-self.frame.origin.x, y, width, panelHeight);
}

- (CGFloat)captionHeightForWidth:(CGFloat)__unused width
{
    CGFloat height = 0.0f;
    
    if ([_textModel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        return height;
    
    return _textModel.frame.size.height;
}

- (CGFloat)captionWidthForWidth:(CGFloat)width
{
    return width - TGGenericPeerMediaGalleryDefaultFooterViewCaptionOrigin.x * 2;
}

- (void)setTransitionOutProgress:(CGFloat)__unused transitionOutProgress manual:(bool)__unused manual
{
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_groupPanelView.frame.size.height > FLT_EPSILON && CGRectContainsPoint(_groupPanelView.frame, point))
        return true;
    
    if (_videoPanelView.frame.size.height > FLT_EPSILON && CGRectContainsPoint(_videoPanelView.frame, point))
        return true;
    
    if (_captionPanelView.frame.size.height > FLT_EPSILON && CGRectContainsPoint(_captionPanelView.frame, point))
        return true;
    
    return [super pointInside:point withEvent:event];
}

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat spacing = 1.0f;
    
    CGSize nameSize = [_nameLabel.text sizeWithFont:_nameLabel.font];
    nameSize.width = MIN(self.frame.size.width - 10.0f, nameSize.width);
    CGSize dateSize = [_dateLabel.text sizeWithFont:_dateLabel.font];
    dateSize.width = MIN(self.frame.size.width - 10.0f, dateSize.width);
    
    _nameLabel.frame = (CGRect){{CGFloor((self.frame.size.width - nameSize.width) / 2.0f), CGFloor((self.frame.size.height - nameSize.height - dateSize.height - spacing) / 2.0f)}, nameSize};
    _dateLabel.frame = (CGRect){{CGFloor((self.frame.size.width - dateSize.width) / 2.0f), CGRectGetMaxY(_nameLabel.frame) + spacing}, dateSize};
    
    CGFloat parentWidth = self.superview.frame.size.width - _safeAreaInset.left - _safeAreaInset.right;
    CGFloat captionWidth = 0.0f;
    if (_textModel.text.length > 0)
    {
        captionWidth = [self captionWidthForWidth:parentWidth];
        if ([_textModel layoutNeedsUpdatingForContainerSize:CGSizeMake(captionWidth, CGFLOAT_MAX)])
            [_textModel layoutForContainerSize:CGSizeMake(captionWidth, CGFLOAT_MAX)];
        
        CGSize targetSize = CGSizeMake(captionWidth, [self captionHeightForWidth:captionWidth]);
        if (fabs(targetSize.width - _captionView.frame.size.width) > FLT_EPSILON || fabs(targetSize.height - _captionView.frame.size.height) > FLT_EPSILON)
        {
            _captionView.frame = CGRectMake(TGGenericPeerMediaGalleryDefaultFooterViewCaptionOrigin.x + _safeAreaInset.left, 8.0f, targetSize.width, targetSize.height);
            [_captionView setNeedsDisplay];
        }
    }
    
    _groupPanelView.frame = [self groupPanelFrameForParentWidth:self.superview.frame.size.width inGroup:_currentGroupedId != 0];
    _groupSliderView.frame = CGRectOffset(_groupPanelView.bounds, 0.0f, 1.0f);
    _captionPanelView.frame = [self captionPanelFrameForParentWidth:self.superview.frame.size.width captionHeight:[self captionHeightForWidth:captionWidth] inGroup:_currentGroupedId != 0 isVideo:_isVideo];
    _videoPanelView.frame = [self videoPanelFrameForParentWidth:self.superview.frame.size.width inGroup:_currentGroupedId != 0 isVideo:_isVideo];
    
    _customContentView.frame = CGRectMake(_safeAreaInset.left, 0.0f, parentWidth, 43.0f);
}

@end
