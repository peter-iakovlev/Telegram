#import "TGModernGalleryItem.h"
#import "TGWebSearchResultsGalleryItem.h"
#import "TGModernGalleryEditableItem.h"

#import "TGGiphySearchResultItem.h"

@interface TGWebSearchResultsGalleryGifItem : NSObject <TGModernGalleryItem, TGWebSearchResultsGalleryItem, TGModernGalleryEditableItem>

@property (nonatomic, strong, readonly) TGGiphySearchResultItem *webSearchResult;

- (instancetype)initWithGiphySearchResultItem:(TGGiphySearchResultItem *)searchResultItem;

@end
