#import <LegacyComponents/TGModernMediaListItem.h>
#import "TGWebSearchListItem.h"

#import "TGModernMediaListEditableItem.h"

#import "TGBingSearchResultItem.h"

@interface TGWebSearchImageItem : NSObject <TGModernMediaListItem, TGWebSearchListItem, TGModernMediaListEditableItem>

@property (nonatomic, strong, readonly) NSString *previewUrl;
@property (nonatomic, strong, readonly) TGBingSearchResultItem *webSearchResult;

- (instancetype)initWithPreviewUrl:(NSString *)previewUrl searchResultItem:(TGBingSearchResultItem *)searchResultItem;

@end
