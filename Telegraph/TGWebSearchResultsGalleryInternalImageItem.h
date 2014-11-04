#import "TGModernGalleryImageItem.h"
#import "TGWebSearchResultsGalleryItem.h"

#import "TGWebSearchInternalImageResult.h"

@interface TGWebSearchResultsGalleryInternalImageItem : TGModernGalleryImageItem <TGWebSearchResultsGalleryItem>

@property (nonatomic, strong, readonly) TGWebSearchInternalImageResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGWebSearchInternalImageResult *)searchResult;

@end
