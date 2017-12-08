#import <LegacyComponents/TGModernGalleryItem.h>
#import "TGWebSearchResultsGalleryItem.h"
#import <LegacyComponents/TGModernGalleryEditableItem.h>

#import "TGInternalGifSearchResult.h"

@interface TGInternalGifSearchResultGalleryItem : NSObject <TGModernGalleryItem, TGWebSearchResultsGalleryItem, TGModernGalleryEditableItem>

@property (nonatomic, strong, readonly) TGInternalGifSearchResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGInternalGifSearchResult *)searchResult;

@end
