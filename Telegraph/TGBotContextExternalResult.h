#import "TGBotContextResult.h"

@interface TGBotContextExternalResult : TGBotContextResult <NSCoding>

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSString *displayUrl;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *pageDescription;
@property (nonatomic, strong, readonly) NSString *thumbUrl;
@property (nonatomic, strong, readonly) NSString *originalUrl;
@property (nonatomic, strong, readonly) NSString *contentType;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) int32_t duration;

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId sendMessage:(id)sendMessage url:(NSString *)url displayUrl:(NSString *)displayUrl type:(NSString *)type title:(NSString *)title pageDescription:(NSString *)pageDescription thumbUrl:(NSString *)thumbUrl originalUrl:(NSString *)originalUrl contentType:(NSString *)contentType size:(CGSize)size duration:(int32_t)duration;

@end
