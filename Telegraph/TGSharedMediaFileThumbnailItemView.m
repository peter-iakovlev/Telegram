#import "TGSharedMediaFileThumbnailItemView.h"

#import "TGDocumentMediaAttachment.h"

#import "TGFont.h"
#import "TGImageView.h"
#import "TGViewController.h"
#import "TGSharedMediaUtils.h"

#import "TGSharedFileSignals.h"

#import "TGSharedMediaAvailabilityState.h"
#import "TGSharedMediaFileThumbnailView.h"
#import "TGSharedMediaFileThumbnailLabelView.h"

@interface TGSharedMediaFileThumbnailItemView ()
{
    TGImageView *_imageView;
    NSString *_legacyThumbnailUrl;
    TGDocumentMediaAttachment *_documentAttachment;
    TGSharedMediaAvailabilityState *_availabilityState;
    
    TGSharedMediaFileThumbnailView *_genericThumbnailView;
    TGSharedMediaFileThumbnailLabelView *_genericThumbnailLabelView;
    
    UIView *_progressView;
}

@end

@implementation TGSharedMediaFileThumbnailItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] init];
        _imageView.backgroundColor = [UIColor lightGrayColor];
        
        _genericThumbnailView = [[TGSharedMediaFileThumbnailView alloc] init];
        _genericThumbnailLabelView = [[TGSharedMediaFileThumbnailLabelView alloc] init];
        [self.contentView insertSubview:_genericThumbnailLabelView atIndex:0];
        
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = TGAccentColor();
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView reset];
}

- (UIView *)transitionView
{
    return _imageView;
}

- (void)updateItemHidden
{
    _imageView.hidden = self.isItemHidden(self.item);
}

- (void)imageThumbnailUpdated:(NSString *)thumbnaiUri
{
    if ([thumbnaiUri isEqualToString:_legacyThumbnailUrl])
    {
        [_imageView setSignal:[self _imageSignal]];
    }
}

- (void)setDocumentMediaAttachment:(TGDocumentMediaAttachment *)documentMediaAttachment availabilityState:(TGSharedMediaAvailabilityState *)__unused availabilityState thumbnailColors:(NSArray *)thumbnailColors
{
    _documentAttachment = documentMediaAttachment;
    
    _legacyThumbnailUrl = [documentMediaAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
    if (_legacyThumbnailUrl == nil)
    {
        [_imageView removeFromSuperview];
        [_genericThumbnailView setStyle:TGSharedMediaFileThumbnailViewStylePlain colors:thumbnailColors];
        if (_genericThumbnailView.superview == nil)
            [self.contentView insertSubview:_genericThumbnailView atIndex:0];
    }
    else
    {
        [_genericThumbnailView removeFromSuperview];
        if (_imageView.superview == nil)
            [self.contentView insertSubview:_imageView atIndex:0];
        
        [_imageView setSignal:[self _imageSignal]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_documentAttachment.fileName attributes:@{}];
    
    [attributedString addAttributes:@{
        NSFontAttributeName: TGSystemFontOfSize(12.0f),
        NSForegroundColorAttributeName: [UIColor whiteColor]
    }
    range:NSMakeRange(0, attributedString.length)];
    
    NSString *extension = [_documentAttachment.fileName pathExtension];
    if (extension.length != 0)
    {
        [attributedString addAttributes:@{
            NSFontAttributeName: TGMediumSystemFontOfSize(12.0f),
        }
        range:NSMakeRange(attributedString.length - extension.length, extension.length)];
    }
    
    [_genericThumbnailLabelView setAttributedString:attributedString displayBackground:_legacyThumbnailUrl != nil];
    [_genericThumbnailLabelView sizeToFit];
    [self setNeedsLayout];
    
    [self updateItemHidden];
    
    [self setAvailabilityState:availabilityState animated:false];
}

- (SSignal *)_imageSignal
{
    return [TGSharedFileSignals squareFileThumbnail:_documentAttachment ofSize:![TGViewController isWidescreen] ? CGSizeMake(70.0f, 70.0f) : CGSizeMake(90.0f, 90.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:nil];
}

- (void)setAvailabilityState:(TGSharedMediaAvailabilityState *)availabilityState animated:(bool)animated
{
    _availabilityState = availabilityState;
    
    switch (availabilityState.type)
    {
        case TGSharedMediaAvailabilityStateAvailable:
        case TGSharedMediaAvailabilityStateNotAvailable:
        {
            [_progressView removeFromSuperview];
            
            break;
        }
        case TGSharedMediaAvailabilityStateDownloading:
        {
            if (_progressView.superview == nil)
            {
                animated = false;
                [self.contentView addSubview:_progressView];
            }
            
            if (animated)
            {
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^
                {
                    [self layoutProgress];
                } completion:nil];
            }
            else
                [self layoutProgress];
            
            break;
        }
    }
}

- (void)layoutProgress
{
    CGFloat inset = 1.0f;
    _progressView.frame = CGRectMake(inset, self.frame.size.height - inset - 2.0f, (self.frame.size.width - inset * 2.0f) * _availabilityState.progress, 2.0f);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    _genericThumbnailView.frame = self.bounds;
    
    [_genericThumbnailLabelView sizeToFit];
    _genericThumbnailLabelView.frame = (CGRect){{CGFloor((self.frame.size.width - _genericThumbnailLabelView.frame.size.width) / 2.0f), 1.0f + CGFloor((self.frame.size.height - _genericThumbnailLabelView.frame.size.height) / 2.0f)}, _genericThumbnailLabelView.frame.size};
    
    [self layoutProgress];
}

@end
