#import "TGModernGalleryItem.h"
#import "TGWebSearchResultsGalleryItem.h"
#import "TGModernGalleryEditableItem.h"

#import "TGWebSearchInternalGifResult.h"

@interface TGWebSearchResultsGalleryInternalGifItem : NSObject <TGModernGalleryItem, TGWebSearchResultsGalleryItem, TGModernGalleryEditableItem>

@property (nonatomic, strong, readonly) TGWebSearchInternalGifResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGWebSearchInternalGifResult *)searchResult;

@end
