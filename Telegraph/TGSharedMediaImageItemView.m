#import "TGSharedMediaImageItemView.h"

#import "TGImageMediaAttachment.h"
#import "TGImageUtils.h"
#import "TGRemoteImageView.h"
#import "TGStringUtils.h"
#import "TGImageView.h"

#import "TGModernCache.h"

#import "TGSharedMediaImageViewQueue.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGViewController.h"

@interface TGSharedMediaImageItemView ()
{
    TGImageView *_imageView;
    NSString *_legacyThumbnailUrl;
    TGImageMediaAttachment *_imageAttachment;
}

@end

@implementation TGSharedMediaImageItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] init];
        [self.contentView insertSubview:_imageView atIndex:0];
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

- (void)setImageMediaAttachment:(TGImageMediaAttachment *)imageMediaAttachment messageId:(int32_t)__unused messageId peerId:(int64_t)__unused peerId
{
    _imageAttachment = imageMediaAttachment;
    TGImageInfo *legacyImageInfo = [imageMediaAttachment imageInfo];
    
    NSString *legacyThumbnailCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    _legacyThumbnailUrl = legacyThumbnailCacheUrl;
    
    [_imageView setSignal:[self _imageSignal]];
    
    [self updateItemHidden];
}

- (SSignal *)_imageSignal
{
    return [TGSharedPhotoSignals squarePhotoThumbnail:_imageAttachment ofSize:![TGViewController isWidescreen] ? CGSizeMake(70.0f, 70.0f) : CGSizeMake(90.0f, 90.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:nil downloadLargeImage:false placeholder:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
}

@end
