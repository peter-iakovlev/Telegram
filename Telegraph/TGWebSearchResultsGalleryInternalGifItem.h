#import "TGModernGalleryItem.h"
#import "TGWebSearchResultsGalleryItem.h"

#import "TGWebSearchInternalGifResult.h"

@interface TGWebSearchResultsGalleryInternalGifItem : NSObject <TGModernGalleryItem, TGWebSearchResultsGalleryItem>

@property (nonatomic, strong, readonly) TGWebSearchInternalGifResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGWebSearchInternalGifResult *)searchResult;

@end
