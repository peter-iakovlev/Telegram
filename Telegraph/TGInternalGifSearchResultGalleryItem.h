#import "TGModernGalleryItem.h"
#import "TGWebSearchResultsGalleryItem.h"

#import "TGInternalGifSearchResult.h"

@interface TGInternalGifSearchResultGalleryItem : NSObject <TGModernGalleryItem, TGWebSearchResultsGalleryItem>

@property (nonatomic, strong, readonly) TGInternalGifSearchResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGInternalGifSearchResult *)searchResult;

@end
