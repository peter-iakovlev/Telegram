#import <LegacyComponents/TGModernMediaListItem.h>
#import "TGWebSearchListItem.h"

#import "TGWebSearchInternalGifResult.h"

@interface TGWebSearchInternalGifItem : NSObject <TGModernMediaListItem, TGWebSearchListItem>

@property (nonatomic, strong, readonly) TGWebSearchInternalGifResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGWebSearchInternalGifResult *)searchResult;

@end
