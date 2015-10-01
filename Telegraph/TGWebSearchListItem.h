#import "TGWebSearchResult.h"
#import "TGModernMediaListItem.h"
#import "TGModernMediaListSelectableItem.h"

@protocol TGWebSearchListItem <TGModernMediaListItem, TGModernMediaListSelectableItem>

- (id<TGWebSearchResult>)webSearchResult;

@end
