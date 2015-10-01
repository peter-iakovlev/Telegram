#import "TGModernGalleryItem.h"
#import "TGWebSearchResultsGalleryItem.h"

#import "TGGiphySearchResultItem.h"

@interface TGWebSearchResultsGalleryGifItem : NSObject <TGModernGalleryItem, TGWebSearchResultsGalleryItem>

@property (nonatomic, strong, readonly) TGGiphySearchResultItem *webSearchResult;

- (instancetype)initWithGiphySearchResultItem:(TGGiphySearchResultItem *)searchResultItem;

@end
