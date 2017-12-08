#import <LegacyComponents/TGModernMediaListItem.h>
#import "TGWebSearchListItem.h"

#import "TGGiphySearchResultItem.h"

@interface TGWebSearchGifItem : NSObject <TGModernMediaListItem, TGWebSearchListItem>

@property (nonatomic, strong, readonly) NSString *previewUrl;
@property (nonatomic, strong, readonly) TGGiphySearchResultItem *webSearchResult;

- (instancetype)initWithPreviewUrl:(NSString *)previewUrl searchResultItem:(TGGiphySearchResultItem *)searchResultItem;

@end
