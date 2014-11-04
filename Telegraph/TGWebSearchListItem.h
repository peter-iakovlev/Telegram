#import "TGWebSearchResult.h"
#import "TGModernMediaListItem.h"

@protocol TGWebSearchListItem <TGModernMediaListItem>

- (id<TGWebSearchResult>)webSearchResult;

@end
