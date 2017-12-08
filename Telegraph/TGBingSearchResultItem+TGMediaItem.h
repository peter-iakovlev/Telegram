#import "TGBingSearchResultItem.h"
#import <LegacyComponents/TGMediaSelectionContext.h>
#import <LegacyComponents/TGMediaEditingContext.h>

@interface TGBingSearchResultItem (TGMediaItem) <TGMediaSelectableItem, TGMediaEditableItem>

@property (nonatomic, copy) void (^fetchOriginalImage)(id<TGMediaEditableItem>, void (^)(UIImage *));
@property (nonatomic, copy) void (^fetchOriginalThumbnailImage)(id<TGMediaEditableItem>, void (^)(UIImage *));

@end
