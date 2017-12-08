#import "TGGenericPeerMediaGalleryDefaultFooterView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGGenericPeerGalleryItem.h"

#import "TGItemCollectionGalleryItem.h"
#import "TGSecretPeerMediaGalleryImageItem.h"
#import "TGSecretPeerMediaGalleryVideoItem.h"
#import "TGUserAvatarGalleryItem.h"
#import "TGGroupAvatarGalleryItem.h"
#import "TGGenericPeerGalleryGroupItem.h"

#import "TGGenericPeerMediaGalleryGroupSliderView.h"

const CGPoint TGGenericPeerMediaGalleryDefaultFooterViewCaptionOrigin = { 13.0f, -8.0f };

@interface TGGenericPeerMediaGalleryDefaultFooterView ()
{
    bool _hasAppeared;
    UIEdgeInsets _safeAreaInset;
    
    UILabel *_nameLabel;
    UILabel *_dateLabel;
    
    UIView *_captionPanelView;
    UILabel *_captionLabel;
    
    UIView *_groupPanelView;
    TGGenericPeerMediaGalleryGroupSliderView *_groupSliderView;
    int64_t _currentGroupedId;
    
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
        
        _captionLabel = [[UILabel alloc] init];
        _captionLabel.backgroundColor = [UIColor clearColor];
        _captionLabel.opaque = false;
        _captionLabel.font = TGSystemFontOfSize(16);
        _captionLabel.numberOfLines = 0;
        _captionLabel.textColor = [UIColor whiteColor];
        [_captionPanelView addSubview:_captionLabel];
        
        _groupPanelView = [[UIView alloc] initWithFrame:CGRectZero];
        _groupPanelView.backgroundColor = UIColorRGBA(0x000000, 0.65f);
        _groupPanelView.clipsToBounds = true;
        [self addSubview:_groupPanelView];
        
        _groupSliderView = [[TGGenericPeerMediaGalleryGroupSliderView alloc] init];
        [_groupPanelView addSubview:_groupSliderView];
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

- (void)setItem:(id<TGModernGalleryItem>)item
{
    if (![item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)] && ![item isKindOfClass:[TGItemCollectionGalleryItem class]] && ![item isKindOfClass:[TGSecretPeerMediaGalleryImageItem class]] && ![item isKindOfClass:[TGSecretPeerMediaGalleryVideoItem class]] && ![item isKindOfClass:[TGUserAvatarGalleryItem class]] && ![item isKindOfClass:[TGGroupAvatarGalleryItem class]])
        return;
    
    bool shouldAnimate = _hasAppeared;

    NSString *newCaption = nil;
    NSArray *groupItems = nil;
    int64_t groupedId = 0;
    int64_t groupedKeyId = 0;
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
    
    if ([_captionLabel.text isEqualToString:newCaption] && groupedId == _currentGroupedId)
    {
        [self setNeedsLayout];
        return;
    }

    _captionHeightForWidth = [[NSMutableDictionary alloc] init];
    bool groupChanged = _currentGroupedId != groupedId;
    _currentGroupedId = groupedId;
    
    UIView *captionSnapshotView = nil;
    if (shouldAnimate && !_captionLabel.hidden)
    {
        captionSnapshotView = [_captionLabel snapshotViewAfterScreenUpdates:false];
        captionSnapshotView.frame = _captionLabel.frame;
        [_captionPanelView insertSubview:captionSnapshotView belowSubview:_captionLabel];
        
        _captionLabel.alpha = 0.0f;
        _captionLabel.hidden = true;
    }
    
    _captionLabel.text = newCaption;
    if (!shouldAnimate)
    {
        _captionLabel.hidden = (_captionLabel.text.length == 0);
        _captionLabel.alpha = _captionLabel.hidden ? 0.0f : 1.0f;
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
    
    if (groupedId != 1)
        [_groupSliderView setGroupedId:groupedId items:groupItems];
    if (groupedId != 0 && groupedKeyId != NSNotFound)
        [_groupSliderView setCurrentItemKey:groupedKeyId animated:false];
    
    if (!shouldAnimate)
    {
        _groupSliderView.hidden = groupedId == 0;
        _groupSliderView.alpha = _groupSliderView.hidden ? 0.0f : 1.0f;
    }
    
    CGFloat fadeOutDuration = 0.21f;
    if (shouldAnimate)
    {
        CGFloat parentWidth = self.superview.frame.size.width;
        CGRect captionTargetFrame = [self captionPanelFrameForParentWidth:parentWidth captionHeight:[self captionHeightForWidth:parentWidth] inGroup:_currentGroupedId != 0];
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

        if (_captionLabel.text.length > 0)
        {
            _captionLabel.hidden = false;
            [UIView animateWithDuration:0.24f delay:fadeInDelay options:UIViewAnimationOptionCurveEaseInOut animations:^
            {
                _captionLabel.alpha = 1.0f;
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

- (CGRect)captionPanelFrameForParentWidth:(CGFloat)width captionHeight:(CGFloat)captionHeight inGroup:(bool)inGroup
{
    CGFloat panelHeight = captionHeight > FLT_EPSILON ? captionHeight + 17.0f : 0.0f;
    CGFloat y = -panelHeight;
    if (inGroup)
        y -= 43.0f;
    return CGRectMake(-self.frame.origin.x, y, width, panelHeight);
}

- (CGRect)groupPanelFrameForParentWidth:(CGFloat)width inGroup:(bool)inGroup
{
    CGFloat panelHeight = inGroup > FLT_EPSILON ? 43.0f : 0.0f;
    return CGRectMake(-self.frame.origin.x, -panelHeight, width, panelHeight);
}

- (CGFloat)captionHeightForWidth:(CGFloat)width
{
    CGFloat height = 0.0f;
    
    if (_captionLabel.text.length == 0)
        return height;
    
    NSNumber *widthKey = @(width);
    NSNumber *cachedHeight = _captionHeightForWidth[widthKey];
    if (cachedHeight == nil)
    {
        if ([_captionLabel.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
        {
            height = [_captionLabel.text boundingRectWithSize:CGSizeMake([self captionWidthForWidth:width], FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_captionLabel.font} context:NULL].size.height;
        }
        else
        {
            height = [_captionLabel.text sizeWithFont:_captionLabel.font constrainedToSize:CGSizeMake([self captionWidthForWidth:width], FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
        }
        _captionHeightForWidth[widthKey] = @(height);
    }
    else
    {
        height = cachedHeight.floatValue;
    }
    
    return height;
}

- (CGFloat)captionWidthForWidth:(CGFloat)width
{
    return width - TGGenericPeerMediaGalleryDefaultFooterViewCaptionOrigin.x * 2;
}

- (void)setTransitionOutProgress:(CGFloat)__unused transitionOutProgress manual:(bool)__unused manual
{
}

- (void)setCaptionPanelHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        _captionPanelView.hidden = false;
        _groupPanelView.hidden = false;

        [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^
        {
            _captionPanelView.alpha = hidden ? 0.0f : 1.0f;
            _groupPanelView.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _captionPanelView.hidden = hidden;
                _groupPanelView.hidden = hidden;
            }
        }];
    }
    else
    {
        _captionPanelView.alpha = hidden ? 0.0f : 1.0f;
        _captionPanelView.hidden = hidden;
        
        _groupPanelView.alpha = hidden ? 0.0f : 1.0f;;
        _groupPanelView.hidden = hidden;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_groupPanelView.frame.size.height > FLT_EPSILON && CGRectContainsPoint(_groupPanelView.frame, point))
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
    if (_captionLabel.text.length > 0)
    {
        captionWidth = [self captionWidthForWidth:parentWidth];
        _captionLabel.frame = CGRectMake(TGGenericPeerMediaGalleryDefaultFooterViewCaptionOrigin.x + _safeAreaInset.left, 8, CGCeil(captionWidth), CGCeil([self captionHeightForWidth:captionWidth]));
    }
    
    _groupPanelView.frame = [self groupPanelFrameForParentWidth:parentWidth inGroup:_currentGroupedId != 0];
    _groupSliderView.frame = CGRectOffset(_groupPanelView.bounds, 0.0f, 1.0f);
    _captionPanelView.frame = [self captionPanelFrameForParentWidth:parentWidth captionHeight:[self captionHeightForWidth:captionWidth] inGroup:_currentGroupedId != 0];
}

@end
