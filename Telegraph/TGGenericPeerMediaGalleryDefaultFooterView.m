#import "TGGenericPeerMediaGalleryDefaultFooterView.h"

#import "TGGenericPeerGalleryItem.h"

#import "TGFont.h"

#import "TGUser.h"
#import "TGConversation.h"
#import "TGDateUtils.h"

#import "TGItemCollectionGalleryItem.h"
#import "TGSecretPeerMediaGalleryImageItem.h"
#import "TGSecretPeerMediaGalleryVideoItem.h"

const CGPoint TGGenericPeerMediaGalleryDefaultFooterViewCaptionOrigin = { 13.0f, -8.0f };

@interface TGGenericPeerMediaGalleryDefaultFooterView ()
{
    bool _hasAppeared;
    
    UILabel *_nameLabel;
    UILabel *_dateLabel;
    
    UIView *_captionPanelView;
    UILabel *_captionLabel;
    
    NSMutableDictionary *_captionHeightForWidth;
}
@end

@implementation TGGenericPeerMediaGalleryDefaultFooterView

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
    }
    return self;
}

- (void)setItem:(id<TGModernGalleryItem>)item
{
    if (![item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)] && ![item isKindOfClass:[TGItemCollectionGalleryItem class]] && ![item isKindOfClass:[TGSecretPeerMediaGalleryImageItem class]] && ![item isKindOfClass:[TGSecretPeerMediaGalleryVideoItem class]])
        return;

    NSString *newCaption = nil;
    if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)]) {
        id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
        NSString *title = nil;
        if ([[concreteItem authorPeer] isKindOfClass:[TGUser class]]) {
            title = ((TGUser *)[concreteItem authorPeer]).displayName;
        } else if ([[concreteItem authorPeer] isKindOfClass:[TGConversation class]]) {
            title = ((TGConversation *)[concreteItem authorPeer]).chatTitle;
        }
        _nameLabel.text = title;
        _dateLabel.text = [TGDateUtils stringForApproximateDate:(int)[concreteItem date]];
        
        if ([concreteItem respondsToSelector:@selector(caption)])
            newCaption = [concreteItem performSelector:@selector(caption) withObject:nil];
    } else if ([item isKindOfClass:[TGItemCollectionGalleryItem class]]) {
        newCaption = [((TGItemCollectionGalleryItem *)item).media caption];
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
    }
    
    if ([_captionLabel.text isEqualToString:newCaption])
    {
        [self setNeedsLayout];
        return;
    }

    _captionHeightForWidth = [[NSMutableDictionary alloc] init];
    
    bool shouldAnimateCaption = _hasAppeared;
    _hasAppeared = true;
    
    UIView *snapshotView = nil;
    if (shouldAnimateCaption && !_captionLabel.hidden)
    {
        snapshotView = [_captionLabel snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = _captionLabel.frame;
        [_captionPanelView insertSubview:snapshotView belowSubview:_captionLabel];
        
        _captionLabel.alpha = 0.0f;
        _captionLabel.hidden = true;
    }
    
    _captionLabel.text = newCaption;
    if (!shouldAnimateCaption)
    {
        _captionLabel.hidden = (_captionLabel.text.length == 0);
        _captionLabel.alpha = _captionLabel.hidden ? 0.0f : 1.0f;
    }
    
    CGFloat fadeOutDuration = 0.21f;
    if (shouldAnimateCaption)
    {
        CGFloat parentWidth = self.superview.frame.size.width;
        CGRect targetFrame = [self captionPanelFrameForParentWidth:parentWidth
                                                     captionHeight:[self captionHeightForWidth:parentWidth]];
        if (targetFrame.size.height < FLT_EPSILON)
            fadeOutDuration = 0.17f;
        
        CGFloat fadeInDelay = 0.08f;
        if (ABS(targetFrame.size.height - _captionPanelView.frame.size.height) > 0)
        {
            fadeInDelay = 0.11f;
            
            [UIView animateWithDuration:0.3f delay:0.0f options:7 << 16 animations:^
            {
                _captionPanelView.frame = targetFrame;
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
    }
    
    if (snapshotView != nil)
    {
        [UIView animateWithDuration:fadeOutDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            snapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
    }
    
    [self setNeedsLayout];
}

- (void)setContentHidden:(bool)contentHidden
{
    _nameLabel.hidden = contentHidden;
    _dateLabel.hidden = contentHidden;
}

- (CGRect)captionPanelFrameForParentWidth:(CGFloat)width captionHeight:(CGFloat)captionHeight
{
    CGFloat panelHeight = captionHeight > FLT_EPSILON ? captionHeight + 17.0f : 0.0f;
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

- (void)setTransitionOutProgress:(CGFloat)transitionOutProgress
{
    if (transitionOutProgress > FLT_EPSILON)
        [self setCaptionPanelHidden:true animated:true];
    else
        [self setCaptionPanelHidden:false animated:true];
}

- (void)setCaptionPanelHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        _captionPanelView.hidden = false;

        [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^
        {
            _captionPanelView.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
                _captionPanelView.hidden = hidden;
        }];
    }
    else
    {
        _captionPanelView.alpha = hidden ? 0.0f : 1.0f;
        _captionPanelView.hidden = hidden;
    }
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
    
    CGFloat parentWidth = self.superview.frame.size.width;
    if (_captionLabel.text.length > 0)
    {
        CGFloat captionWidth = [self captionWidthForWidth:parentWidth];
        _captionLabel.frame = CGRectMake(TGGenericPeerMediaGalleryDefaultFooterViewCaptionOrigin.x, 8, CGCeil(captionWidth), CGCeil([self captionHeightForWidth:captionWidth]));
    }
    
    _captionPanelView.frame = [self captionPanelFrameForParentWidth:parentWidth captionHeight:[self captionHeightForWidth:parentWidth]];
}

@end
