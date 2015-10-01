#import "TGWebSearchResultsGalleryImageItem.h"

#import "TGWebSearchResultsGalleryImageItemView.h"

#import "TGBingSearchResultItem+TGEditablePhotoItem.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"

@interface TGWebSearchResultsGalleryImageItem ()
{
    NSString *_imageUrl;
}

@end

@implementation TGWebSearchResultsGalleryImageItem

@synthesize itemSelected = _itemSelected;

- (instancetype)initWithImageUrl:(NSString *)imageUrl imageSize:(CGSize)imageSize searchResultItem:(TGBingSearchResultItem *)searchResultItem
{
    CGSize fittedSize = TGFitSize(imageSize, CGSizeMake(1600, 1600));
    NSString *uri = [[NSString alloc] initWithFormat:@"web-search-gallery://?url=%@&thumbnailUrl=%@&width=%d&height=%d", [TGStringUtils stringByEscapingForURL:searchResultItem.imageUrl], [TGStringUtils stringByEscapingForURL:searchResultItem.previewUrl], (int)fittedSize.width, (int)fittedSize.height];
    self = [super initWithUri:uri imageSize:fittedSize];
    if (self != nil)
    {
        _imageUrl = imageUrl;
        _webSearchResult = searchResultItem;
    }
    return self;
}

- (Class)viewClass
{
    return [TGWebSearchResultsGalleryImageItemView class];
}

- (id<TGEditablePhotoItem>)editableMediaItem
{
    return self.webSearchResult;
}

- (NSString *)uniqueId
{
    return [self.webSearchResult uniqueId];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchResultsGalleryImageItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchResultsGalleryImageItem *)object)->_webSearchResult);
}

@end
