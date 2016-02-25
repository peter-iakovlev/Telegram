#import "TGModernGalleryItem.h"
#import "TGWebSearchResultsGalleryItem.h"

#import "TGExternalGifSearchResult.h"

@interface TGExternalGifSearchResultGalleryItem : NSObject <TGModernGalleryItem, TGWebSearchResultsGalleryItem>

@property (nonatomic, strong, readonly) TGExternalGifSearchResult *webSearchResult;

- (instancetype)initWithSearchResultItem:(TGExternalGifSearchResult *)searchResultItem;

@end
