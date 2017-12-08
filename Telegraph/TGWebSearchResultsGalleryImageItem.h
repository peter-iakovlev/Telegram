#import <LegacyComponents/TGModernGalleryImageItem.h>
#import "TGWebSearchResultsGalleryItem.h"
#import <LegacyComponents/TGModernGalleryEditableItem.h>

#import "TGBingSearchResultItem.h"

@interface TGWebSearchResultsGalleryImageItem : TGModernGalleryImageItem <TGWebSearchResultsGalleryItem, TGModernGalleryEditableItem>

@property (nonatomic, strong, readonly) TGBingSearchResultItem *webSearchResult;

- (instancetype)initWithImageUrl:(NSString *)imageUrl imageSize:(CGSize)imageSize searchResultItem:(TGBingSearchResultItem *)searchResultItem;

@end
