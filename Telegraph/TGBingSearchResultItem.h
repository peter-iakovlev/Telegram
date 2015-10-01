#import "TGWebSearchResult.h"

@interface TGBingSearchResultItem : NSObject <TGWebSearchResult>

@property (nonatomic, strong, readonly) NSString *imageUrl;
@property (nonatomic, readonly) CGSize imageSize;

@property (nonatomic, strong, readonly) NSString *previewUrl;
@property (nonatomic, readonly) CGSize previewSize;

- (instancetype)initWithImageUrl:(NSString *)imageUrl imageSize:(CGSize)imageSize previewUrl:(NSString *)previewUrl previewSize:(CGSize)previewSize;

@end
