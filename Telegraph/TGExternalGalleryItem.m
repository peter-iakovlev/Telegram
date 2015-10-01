#import "TGExternalGalleryItem.h"

#import "TGWebPageMediaAttachment.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGExternalGalleryItemView.h"
#import "TGImageUtils.h"

@implementation TGExternalGalleryItem

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage
{
    CGSize imageSize = CGSizeZero;
    [webPage.photo.imageInfo imageUrlForLargestSize:&imageSize];
    
    CGFloat imageAspect = imageSize.width / imageSize.height;
    CGSize fitSize = CGSizeMake(215.0f, 180.0f);
    if (ABS(imageAspect - 1.0f) < FLT_EPSILON)
        fitSize = CGSizeMake(215.0f, 215.0f);
    
    imageSize = TGScaleToFill(imageSize, fitSize);
    imageSize = TGCropSize(imageSize, fitSize);
    
    [webPage.photo.imageInfo imageUrlForSizeLargerThanSize:fitSize actualSize:&imageSize];
    imageSize.width /= ([UIScreen mainScreen].scale > 1.0f + FLT_EPSILON ? 2.0f : 1.0f);
    imageSize.height /= ([UIScreen mainScreen].scale > 1.0f + FLT_EPSILON ? 2.0f : 1.0f);
    NSString *key = [[NSMutableString alloc] initWithFormat:@"webpage-gallery-%lld", (long long int)webPage.webPageId];
    self = [super initWithSignal:[TGSharedPhotoSignals sharedPhotoImage:webPage.photo size:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:nil pixelProcessingBlock:nil cacheKey:key] imageSize:imageSize];
    if (self != nil)
    {
        _webPage = webPage;
    }
    return self;
}

- (Class)viewClass
{
    return [TGExternalGalleryItemView class];
}

@end
