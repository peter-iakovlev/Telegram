#import "TGModernGalleryImageItem.h"
#import "TGWebSearchResultsGalleryItem.h"
#import "TGModernGalleryEditableItem.h"

#import "TGWebSearchInternalImageResult.h"

@interface TGWebSearchResultsGalleryInternalImageItem : TGModernGalleryImageItem <TGWebSearchResultsGalleryItem, TGModernGalleryEditableItem>

@property (nonatomic, strong, readonly) TGWebSearchInternalImageResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGWebSearchInternalImageResult *)searchResult;

@end
