#import "TGPreviewPhotoItemView.h"

#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"
#import "TGImageMediaAttachment.h"
#import "TGImageView.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

@interface TGPreviewPhotoItemView ()
{
    TGImageView *_imageView;
    CGSize _dimensions;
    TGImageMediaAttachment *_attachment;
    
    NSURL *_url;
    NSURL *_thumbUrl;
    
    CGSize _imageSize;
}
@end

@implementation TGPreviewPhotoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    return self;
}

- (instancetype)initWithImageAttachment:(TGImageMediaAttachment *)attachment
{
    self = [self init];
    if (self != nil)
    {
        _attachment = attachment;
        
        CGSize imageSize;
        [attachment.imageInfo imageUrlForLargestSize:&imageSize];
        _dimensions = imageSize;
    }
    return self;
}

- (instancetype)initWithThumbURL:(NSURL *)thumbUrl url:(NSURL *)url size:(CGSize)size
{
    self = [self init];
    if (self != nil)
    {
        _thumbUrl = thumbUrl;
        _url = url;
        _dimensions = size;
    }
    return self;
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willAppearAnimated:(bool)__unused animated
{
    CGSize fitSize = CGSizeMake(128.0f, 128.0f);
    if (_attachment != nil)
    {
        CGSize thumbSize = TGFitSize(TGFillSizeF(_dimensions, fitSize), fitSize);
        
        SSignal *thumbnailSignal = [TGSharedPhotoSignals cachedRemoteThumbnail:_attachment.imageInfo size:thumbSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        
        SSignal *largeSignal = [TGSharedPhotoSignals cachedRemoteThumbnail:_attachment.imageInfo size:_imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        
        [_imageView setSignal:[thumbnailSignal then:largeSignal]];
    }
    else if (_url != nil)
    {
        CGSize thumbSize = TGFitSize(_dimensions, fitSize);
        
        SSignal *thumnailSignal = [TGSharedPhotoSignals cachedExternalThumbnail:_thumbUrl.absoluteString size:thumbSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        
        SSignal *largeSignal = [TGSharedPhotoSignals cachedExternalThumbnail:_url.absoluteString size:_imageSize pixelProcessingBlock:nil cacheVariantKey:@"mediaContextPanel" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        
        [_imageView setSignal:[thumnailSignal then:largeSignal]];
    }
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width screenHeight:(CGFloat)__unused screenHeight
{
    if (_dimensions.width < 1.0f || _dimensions.height < 1.0f) {
        return 1.0f;
    }
    CGSize size = TGScaleToSize(_dimensions, CGSizeMake(width, width * 1.33f));
    _imageSize = TGScaleToFillSize(_dimensions, size);
    return size.height;
}

- (void)layoutSubviews
{
    _imageView.frame = self.bounds;
}

@end
