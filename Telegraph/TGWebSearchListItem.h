#import "TGWebSearchResult.h"
#import <LegacyComponents/TGModernMediaListItem.h>
#import <LegacyComponents/TGModernMediaListSelectableItem.h>

@protocol TGWebSearchListItem <TGModernMediaListItem, TGModernMediaListSelectableItem>

- (id<TGWebSearchResult>)webSearchResult;

@end
