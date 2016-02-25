#import "TGWebSearchInternalImageResult.h"
#import "TGMediaSelectionContext.h"
#import "TGMediaEditingContext.h"

@interface TGWebSearchInternalImageResult (TGMediaEditableItem) <TGMediaSelectableItem, TGMediaEditableItem>

@property (nonatomic, copy) void (^fetchOriginalImage)(id<TGMediaEditableItem>, void (^)(UIImage *));
@property (nonatomic, copy) void (^fetchOriginalThumbnailImage)(id<TGMediaEditableItem>, void (^)(UIImage *));

@end
