#import "TGWebSearchResult.h"
#import "TGModernGalleryItem.h"
#import "TGModernGallerySelectableItem.h"

@protocol TGWebSearchResultsGalleryItem <TGModernGalleryItem, TGModernGallerySelectableItem>

- (id<TGWebSearchResult>)webSearchResult;

@end
