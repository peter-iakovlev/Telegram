#import "TGBotContextResult.h"

@class TGWebDocument;

@interface TGBotContextExternalResult : TGBotContextResult <NSCoding>

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSString *displayUrl;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *pageDescription;
@property (nonatomic, strong, readonly) TGWebDocument *thumb;
@property (nonatomic, strong, readonly) TGWebDocument *content;

@property (nonatomic, strong, readonly) NSString *thumbUrl;
@property (nonatomic, strong, readonly) NSString *originalUrl;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) int32_t duration;

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId sendMessage:(id)sendMessage url:(NSString *)url displayUrl:(NSString *)displayUrl type:(NSString *)type title:(NSString *)title pageDescription:(NSString *)pageDescription thumb:(TGWebDocument *)thumb content:(TGWebDocument *)content;

@end
