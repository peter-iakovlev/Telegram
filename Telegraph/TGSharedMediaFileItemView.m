#import "TGSharedMediaFileItemView.h"

#import "TGDocumentMediaAttachment.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGDateUtils.h"

#import "TGImageView.h"

#import "TGMessageImageViewOverlayView.h"
#import "TGSharedMediaAvailabilityState.h"

#import "TGSharedMediaFileThumbnailView.h"

#import "TGSharedFileSignals.h"
#import "TGViewController.h"
#import "TGSharedMediaUtils.h"

#import "TGSharedMediaCheckButton.h"

@interface TGSharedMediaFileItemView ()
{
    UIView *_separatorView;
    
    UILabel *_titleLabel;
    UILabel *_descriptionLabel;
    NSUInteger _descriptionLabelSize;
    
    TGSharedMediaFileThumbnailView *_genericIconView;
    UILabel *_genericIconExtensionLabel;
    TGImageView *_thumbnailIconView;
    
    NSString *_extension;
    NSString *_legacyThumbnailUrl;
    
    UIView *_progressView;
    
    TGDocumentMediaAttachment *_documentAttachment;
    int32_t _date;
    TGSharedMediaAvailabilityState *_availabilityState;
    
    UIImageView *_availabilityStateIconView;
    
    TGSharedMediaCheckButton *_checkButton;
    
    UIGestureRecognizer *_tapRecognizer;
}

@end

@implementation TGSharedMediaFileItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = UIColorRGB(0xc8c7cc);
        [self.contentView addSubview:_separatorView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(15.0f);
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_titleLabel];
        
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.textColor = UIColorRGB(0xa8a8a8);
        _descriptionLabel.font = TGSystemFontOfSize(13.0f);
        [self.contentView addSubview:_descriptionLabel];
        
        _genericIconView = [[TGSharedMediaFileThumbnailView alloc] init];
        _genericIconExtensionLabel = [[UILabel alloc] init];
        _genericIconExtensionLabel.backgroundColor = [UIColor clearColor];
        _genericIconExtensionLabel.textColor = [UIColor whiteColor];
        _genericIconExtensionLabel.font = TGMediumSystemFontOfSize(13.0f);
        
        _thumbnailIconView = [[TGImageView alloc] init];
        
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = UIColorRGB(0x007ee5);
        
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = UIColorRGB(0xd9d9d9);
        
        _availabilityStateIconView = [[UIImageView alloc] init];
        
        _checkButton = [[TGSharedMediaCheckButton alloc] init];
        _checkButton.userInteractionEnabled = false;
        [self.contentView addSubview:_checkButton];
        
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _tapRecognizer.enabled = false;
        _tapRecognizer.cancelsTouchesInView = true;
        [self.contentView addGestureRecognizer:_tapRecognizer];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _availabilityState = nil;
}

- (UIImage *)availabilityStateIconDownload
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        image = [UIImage imageNamed:@"SharedMediaDocumentStatusDownload.png"];
    });
    return image;
}

- (UIImage *)availabilityStateIconPause
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(11.0f, 11.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0x0080fc).CGColor);
        CGContextFillRect(context, CGRectMake(2.0f, 0.0f, 2.0f, 11.0f - 1.0f));
        CGContextFillRect(context, CGRectMake(2.0f + 2.0f + 2.0f, 0.0f, 2.0f, 11.0f - 1.0f));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (void)setDocumentMediaAttachment:(TGDocumentMediaAttachment *)documentMediaAttachment date:(int)date lastInSection:(bool)__unused lastInSection availabilityState:(TGSharedMediaAvailabilityState *)availabilityState thumbnailColors:(NSArray *)thumbnailColors
{
    _documentAttachment = documentMediaAttachment;
    _date = date;
    
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _titleLabel.text = documentMediaAttachment.fileName;
    
    for (id attribute in _documentAttachment.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
        {
            TGDocumentAttributeAudio *audioAttribute = (TGDocumentAttributeAudio *)attribute;
            NSString *title = documentMediaAttachment.fileName;
            if (audioAttribute.title.length > 0)
            {
                title = audioAttribute.title;

                if (audioAttribute.performer.length > 0)
                    title = [NSString stringWithFormat:@"%@ — %@", audioAttribute.performer, title];
                
                _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                _titleLabel.text = title;
            }
            break;
        }
    }
    
    _separatorView.hidden = false;
    
    bool isSticker = false;
    for (id attribute in documentMediaAttachment.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            isSticker = true;
            break;
        }
    }
    
    _extension = [[documentMediaAttachment.fileName pathExtension] lowercaseString];
    bool useThumbnail = false;
    
    if (!isSticker && documentMediaAttachment.thumbnailInfo != nil && !documentMediaAttachment.thumbnailInfo.empty)
    {
        CGSize dimensions = CGSizeZero;
        NSString *_legacyThumbnailCacheUri = [documentMediaAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
        useThumbnail = true;
        _legacyThumbnailUrl = _legacyThumbnailCacheUri;
    }
    else
    {
        useThumbnail = false;
        _legacyThumbnailUrl = nil;
        [_genericIconView setStyle:TGSharedMediaFileThumbnailViewStyleRounded colors:thumbnailColors];
    }
    
    if (useThumbnail)
        [self setUseThumbnail];
    else
        [self setUseGenericIconWithExtension:_extension];
    
    [self setAvailabilityState:availabilityState animated:false];
    
    [self setNeedsLayout];
}

- (void)addPositionAnimationToLayer:(CALayer *)layer from:(CGPoint)fromPoint to:(CGPoint)toPoint duration:(NSTimeInterval)duration
{
    layer.position = fromPoint;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:fromPoint];
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"position"];
    layer.position = toPoint;
}

- (void)addBoundsAnimationToLayer:(CALayer *)layer from:(CGRect)fromBounds to:(CGRect)toBounds duration:(NSTimeInterval)duration
{
    layer.bounds = fromBounds;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:fromBounds];
    animation.toValue = [NSValue valueWithCGRect:toBounds];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"bounds"];
    layer.bounds = toBounds;
}

- (void)addFrameAnimationToView:(UIView *)view from:(CGRect)fromFrame to:(CGRect)toFrame duration:(NSTimeInterval)duration
{
    
    {
        [view.layer removeAllAnimations];
        
        [self addPositionAnimationToLayer:view.layer from:CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMidY(fromFrame)) to:CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame)) duration:duration];
        [self addBoundsAnimationToLayer:view.layer from:CGRectMake(0.0f, 0.0f, fromFrame.size.width, fromFrame.size.height) to:CGRectMake(0.0f, 0.0f, toFrame.size.width, toFrame.size.height) duration:duration];
    }
}

- (void)setAvailabilityState:(TGSharedMediaAvailabilityState *)availabilityState animated:(bool)animated
{
    if (TGObjectCompare(_availabilityState, availabilityState))
        return;
    
    _availabilityState = availabilityState;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(4.0f, self.editing ? [self editingInset] : 65.0f, 6.0f, 10.0f);
    NSString *descriptionText = nil;
    bool updateLayout = false;
    
    switch (availabilityState.type)
    {
        case TGSharedMediaAvailabilityStateAvailable:
        case TGSharedMediaAvailabilityStateNotAvailable:
        {
            descriptionText = [[NSString alloc] initWithFormat:@"%@ • %@", [TGStringUtils stringForFileSize:_documentAttachment.size], [TGDateUtils stringForPreciseDate:_date]];
            
            if (availabilityState.type == TGSharedMediaAvailabilityStateNotAvailable)
            {
                [_progressView removeFromSuperview];
                if (_availabilityStateIconView.superview == nil)
                {
                    [self addSubview:_availabilityStateIconView];
                    updateLayout = true;
                }
                _availabilityStateIconView.image = [self availabilityStateIconDownload];
            }
            else
            {
                if (_availabilityStateIconView.superview != nil)
                {
                    [_availabilityStateIconView removeFromSuperview];
                    updateLayout = true;
                }
                
                if (_progressView.superview != nil)
                {
                    UIView *animationProgressView = [[UIView alloc] initWithFrame:((CALayer *)_progressView.layer.presentationLayer).frame];
                    animationProgressView.backgroundColor = _progressView.backgroundColor;
                    [[_progressView superview] insertSubview:animationProgressView aboveSubview:_progressView];
                    [_progressView removeFromSuperview];
                    
                    [UIView animateWithDuration:0.15 animations:^
                    {
                        animationProgressView.frame = CGRectMake(insets.left, self.frame.size.height - 2.0f, (self.frame.size.width - insets.left) * 1.0f, 2.0f);
                    } completion:^(BOOL finished)
                    {
                        if (finished)
                        {
                            [UIView animateWithDuration:0.3 animations:^
                            {
                                animationProgressView.alpha = 0.0f;
                            } completion:^(__unused BOOL finished)
                            {
                                [animationProgressView removeFromSuperview];
                            }];
                        }
                        else
                            [animationProgressView removeFromSuperview];
                    }];
                }
            }
            
            break;
        }
        case TGSharedMediaAvailabilityStateDownloading:
        {
            if (_progressView.superview == nil)
            {
                animated = false;
                [self.contentView addSubview:_progressView];
                _progressView.frame = CGRectMake(insets.left, self.frame.size.height - 2.0f, (self.frame.size.width - insets.left) * 0.0f, 2.0f);
            }
            
            _progressView.alpha = 1.0f;
            
            if (animated)
            {
                /*[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^
                {
                    _progressView.frame = CGRectMake(insets.left, self.frame.size.height - 2.0f, (self.frame.size.width - insets.left) * _availabilityState.progress, 2.0f);
                } completion:nil];*/
                
                CALayer *layer = _progressView.layer.presentationLayer;
                if (layer == nil)
                    layer = _progressView.layer;
                [self addFrameAnimationToView:_progressView from:layer.frame to:CGRectMake(insets.left, self.frame.size.height - 2.0f, (self.frame.size.width - insets.left) * _availabilityState.progress, 2.0f) duration:0.2];
            }
            else
            {
                [_progressView.layer removeAllAnimations];
                _progressView.frame = CGRectMake(insets.left, self.frame.size.height - 2.0f, (self.frame.size.width - insets.left) * _availabilityState.progress, 2.0f);
            }
            
            descriptionText = [[NSString alloc] initWithFormat:TGLocalized(@"DownloadingStatus"), [TGStringUtils stringForFileSize:(int32_t)(_documentAttachment.size * availabilityState.progress)], [TGStringUtils stringForFileSize:_documentAttachment.size]];
            
            _availabilityStateIconView.image = [self availabilityStateIconPause];
            updateLayout = true;
            
            break;
        }
    }
    
    if (!TGStringCompare(descriptionText, _descriptionLabel.text))
    {
        _descriptionLabel.text = descriptionText;
        updateLayout = true;
    }
    
    if (updateLayout)
        [self layoutDescriptionLabel];
}

- (void)setUseGenericIconWithExtension:(NSString *)extension
{
    [_thumbnailIconView reset];
    [_thumbnailIconView removeFromSuperview];
    [self.contentView addSubview:_genericIconView];
    [self.contentView addSubview:_genericIconExtensionLabel];
    
    _genericIconExtensionLabel.text = extension.length > 5 ? [extension substringToIndex:5] : extension;
    [_genericIconExtensionLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setUseThumbnail
{
    [_genericIconView removeFromSuperview];
    [_genericIconExtensionLabel removeFromSuperview];
    [self.contentView addSubview:_thumbnailIconView];
    
    [_thumbnailIconView setSignal:[self _imageSignal]];
}
     
 - (void)imageThumbnailUpdated:(NSString *)thumbnaiUri
{
    if ([thumbnaiUri isEqualToString:_legacyThumbnailUrl])
    {
        [_thumbnailIconView setSignal:[self _imageSignal]];
    }
}

- (SSignal *)_imageSignal
{
    return [TGSharedFileSignals squareFileThumbnail:_documentAttachment ofSize:![TGViewController isWidescreen] ? CGSizeMake(70.0f, 70.0f) : CGSizeMake(90.0f, 90.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:nil];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
    {
        UIView *topSibling = nil;
        for (UIView *view in self.superview.subviews.reverseObjectEnumerator)
        {
            if (view != self)
            {
                topSibling = view;
                break;
            }
        }
        if (topSibling != nil)
        {
            [self.superview exchangeSubviewAtIndex:[self.superview.subviews indexOfObject:self] withSubviewAtIndex:[self.superview.subviews indexOfObject:topSibling]];
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        UIView *topSibling = nil;
        for (UIView *view in self.superview.subviews.reverseObjectEnumerator)
        {
            if (view != self)
            {
                topSibling = view;
                break;
            }
        }
        if (topSibling != nil)
        {
            [self.superview exchangeSubviewAtIndex:[self.superview.subviews indexOfObject:self] withSubviewAtIndex:[self.superview.subviews indexOfObject:topSibling]];
        }
    }
}

- (void)layoutDescriptionLabel
{
    UIEdgeInsets insets = UIEdgeInsetsMake(4.0f, self.editing ? [self editingInset] : 65.0f, 7.0f, 10.0f);
    
    if (_availabilityStateIconView.superview != nil)
    {
        _availabilityStateIconView.frame = CGRectMake(insets.left - 1.0f, 32.0f, _availabilityStateIconView.image.size.width, _availabilityStateIconView.image.size.height);
        insets.left += 12.0f;
    }
    
    CGSize descriptionSize = [_descriptionLabel.text sizeWithFont:_descriptionLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - insets.left - insets.right - 1.0f + 1000.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingMiddle];
    descriptionSize.width = CGCeil(descriptionSize.width);
    descriptionSize.height = CGCeil(descriptionSize.height);
    _descriptionLabel.frame = CGRectMake(insets.left + 1.0f, self.frame.size.height - insets.bottom - descriptionSize.height, descriptionSize.width, descriptionSize.height);
}

- (void)setEditing:(bool)editing animated:(bool)animated delay:(NSTimeInterval)delay
{
    [super setEditing:editing animated:animated delay:delay];
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 delay:delay options:[TGViewController preferredAnimationCurve] << 16 animations:^
        {
            [self layoutSubviews];
        } completion:nil];
    }
    
    _tapRecognizer.enabled = editing;
}

- (void)updateItemSelected
{
    [super updateItemSelected];
    
    [_checkButton setChecked:self.isItemSelected && self.item != nil && self.isItemSelected(self.item) animated:false];
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.toggleItemSelection && self.item != nil)
            self.toggleItemSelection(self.item);
        [_checkButton setChecked:self.isItemSelected && self.item != nil && self.isItemSelected(self.item) animated:true];
    }
}

- (CGFloat)editingInset
{
    return 68.0f + 42.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat separatorHeight = TGScreenPixel;
    UIEdgeInsets insets = UIEdgeInsetsMake(8.0f, self.editing ? [self editingInset] : 65.0f, 6.0f, 10.0f);
    _separatorView.frame = CGRectMake(insets.left, self.frame.size.height - separatorHeight, self.frame.size.width - insets.left, separatorHeight);
    
    self.selectedBackgroundView.frame = CGRectMake(0.0f, -separatorHeight, self.frame.size.width, self.frame.size.height + separatorHeight);
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - insets.left - insets.right - 1.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingMiddle];
    titleSize.width = CGCeil(titleSize.width);
    titleSize.height = MIN(21.0f, CGCeil(titleSize.height));
    _titleLabel.frame = CGRectMake(insets.left + 1.0f, insets.top, titleSize.width, titleSize.height);
    
    [self layoutDescriptionLabel];
    
    CGFloat iconOffset = (self.editing ? [self editingInset] : 65.0f) - 65.0f;
    _genericIconView.frame = (CGRect){{9.0f + TGRetinaPixel + iconOffset, 5.0f}, {42.0f, 42.0f}};
    _genericIconExtensionLabel.frame = (CGRect){{CGFloor(_genericIconView.frame.origin.x + (_genericIconView.frame.size.width - _genericIconExtensionLabel.frame.size.width) / 2.0f), 1.0f + CGFloor(_genericIconView.frame.origin.y + (_genericIconView.frame.size.height - _genericIconExtensionLabel.frame.size.height) / 2.0f)}, _genericIconExtensionLabel.frame.size};
    
    _thumbnailIconView.frame = (CGRect){{9.0f + TGRetinaPixel + iconOffset, 5.0f}, {42.0f, 42.0f}};
    
    [_progressView.layer removeAllAnimations];
    _progressView.frame = CGRectMake(insets.left, self.frame.size.height - 2.0f, (self.frame.size.width - insets.left) * _availabilityState.progress, 2.0f);
    
    _checkButton.frame = CGRectMake(self.editing ? 14.0f : -100.0f, 14.0f, 24.0f, 24.0f);
}

@end
