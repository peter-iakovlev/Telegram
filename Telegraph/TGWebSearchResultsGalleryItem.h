#import "TGWebSearchResult.h"
#import <LegacyComponents/TGModernGalleryItem.h>
#import <LegacyComponents/TGModernGallerySelectableItem.h>

@protocol TGWebSearchResultsGalleryItem <TGModernGalleryItem, TGModernGallerySelectableItem>

- (id<TGWebSearchResult>)webSearchResult;

@end
