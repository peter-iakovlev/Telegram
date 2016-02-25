#import "TGModernMediaListImageItem.h"
#import "TGWebSearchListItem.h"

#import "TGModernMediaListEditableItem.h"

#import "TGWebSearchInternalImageResult.h"

@interface TGWebSearchInternalImageItem : TGModernMediaListImageItem <TGWebSearchListItem, TGModernMediaListEditableItem>

@property (nonatomic, strong, readonly) TGWebSearchInternalImageResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGWebSearchInternalImageResult *)searchResult;

@end
