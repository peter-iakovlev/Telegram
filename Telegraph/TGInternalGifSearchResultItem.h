#import <Foundation/Foundation.h>

#import <LegacyComponents/TGModernMediaListItem.h>
#import "TGWebSearchListItem.h"

#import "TGInternalGifSearchResult.h"

@interface TGInternalGifSearchResultItem : NSObject <TGModernMediaListItem, TGWebSearchListItem>

@property (nonatomic, strong, readonly) TGInternalGifSearchResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGInternalGifSearchResult *)searchResult;

@end
