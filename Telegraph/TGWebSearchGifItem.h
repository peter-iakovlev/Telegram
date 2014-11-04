#import "TGModernMediaListItem.h"
#import "TGWebSearchListItem.h"

#import "TGGiphySearchResultItem.h"

@interface TGWebSearchGifItem : NSObject <TGModernMediaListItem, TGWebSearchListItem>

@property (nonatomic, strong, readonly) NSString *previewUrl;
@property (nonatomic, strong, readonly) TGGiphySearchResultItem *webSearchResult;

@property (nonatomic, copy, readonly) void (^itemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy, readonly) bool (^isItemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy, readonly) bool (^isItemHidden)(id<TGWebSearchListItem>);

- (instancetype)initWithPreviewUrl:(NSString *)previewUrl searchResultItem:(TGGiphySearchResultItem *)searchResultItem itemSelected:(void (^)(id<TGWebSearchListItem>))itemSelected isItemSelected:(bool (^)(id<TGWebSearchListItem>))isItemSelected isItemHidden:(bool (^)(id<TGWebSearchListItem>))isItemHidden;

@end
