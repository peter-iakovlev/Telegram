#import "TGModernGalleryImageItem.h"
#import "TGWebSearchResultsGalleryItem.h"

#import "TGBingSearchResultItem.h"

@interface TGWebSearchResultsGalleryImageItem : TGModernGalleryImageItem <TGWebSearchResultsGalleryItem>

@property (nonatomic, strong, readonly) TGBingSearchResultItem *webSearchResult;

- (instancetype)initWithImageUrl:(NSString *)imageUrl imageSize:(CGSize)imageSize searchResultItem:(TGBingSearchResultItem *)searchResultItem;

@end
