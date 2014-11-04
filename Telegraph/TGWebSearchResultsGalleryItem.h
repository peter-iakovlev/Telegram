#import "TGWebSearchResult.h"
#import "TGModernGalleryItem.h"

@protocol TGWebSearchResultsGalleryItem <TGModernGalleryItem>

- (id<TGWebSearchResult>)webSearchResult;

@end
