#import "TGWebSearchResultsGalleryImageItem.h"

#import "TGWebSearchResultsGalleryImageItemView.h"

#import "TGBingSearchResultItem+TGMediaItem.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"

@interface TGWebSearchResultsGalleryImageItem ()
{
    NSString *_imageUrl;
}

@end

@implementation TGWebSearchResultsGalleryImageItem

@synthesize selectionContext;
@synthesize editingContext;

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


- (id<TGMediaSelectableItem>)selectableMediaItem
{
    return self.webSearchResult;
}

- (id<TGMediaEditableItem>)editableMediaItem
{
    return self.webSearchResult;
}

- (TGPhotoEditorTab)toolbarTabs
{
    return TGPhotoEditorCropTab | TGPhotoEditorPaintTab | TGPhotoEditorToolsTab;
}

- (NSString *)uniqueId
{
    return [self.webSearchResult uniqueIdentifier];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchResultsGalleryImageItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchResultsGalleryImageItem *)object)->_webSearchResult);
}

@end
