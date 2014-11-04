#import "TGWebSearchResult.h"

@interface TGGiphySearchResultItem : NSObject <TGWebSearchResult>

@property (nonatomic, strong, readonly) NSString *gifId;

@property (nonatomic, strong, readonly) NSString *gifUrl;
@property (nonatomic, readonly) CGSize gifSize;
@property (nonatomic, readonly) NSUInteger gifFileSize;

@property (nonatomic, strong, readonly) NSString *previewUrl;
@property (nonatomic, readonly) CGSize previewSize;

- (instancetype)initWithGifId:(NSString *)gifId gifUrl:(NSString *)gifUrl gifSize:(CGSize)gifSize gifFileSize:(NSUInteger)gifFileSize previewUrl:(NSString *)previewUrl previewSize:(CGSize)previewSize;

@end
