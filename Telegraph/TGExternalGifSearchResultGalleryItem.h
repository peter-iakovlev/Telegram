#import <LegacyComponents/TGModernGalleryItem.h>
#import "TGWebSearchResultsGalleryItem.h"
#import <LegacyComponents/TGModernGalleryEditableItem.h>

#import "TGExternalGifSearchResult.h"

@interface TGExternalGifSearchResultGalleryItem : NSObject <TGModernGalleryItem, TGWebSearchResultsGalleryItem, TGModernGalleryEditableItem>

@property (nonatomic, strong, readonly) TGExternalGifSearchResult *webSearchResult;

- (instancetype)initWithSearchResultItem:(TGExternalGifSearchResult *)searchResultItem;

@end
