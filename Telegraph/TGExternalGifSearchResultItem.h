#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

#import "TGModernMediaListItem.h"
#import "TGWebSearchListItem.h"

#import "TGExternalGifSearchResult.h"

@interface TGExternalGifSearchResultItem : NSObject <TGModernMediaListItem, TGWebSearchListItem>

@property (nonatomic, strong, readonly) TGExternalGifSearchResult *webSearchResult;

- (instancetype)initWithSearchResult:(TGExternalGifSearchResult *)searchResult;

@end
