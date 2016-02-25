#import "TGBotContextExternalResult.h"

@implementation TGBotContextExternalResult

- (instancetype)initWithQueryId:(int64_t)queryId resultId:(NSString *)resultId sendMessage:(id)sendMessage url:(NSString *)url displayUrl:(NSString *)displayUrl type:(NSString *)type title:(NSString *)title pageDescription:(NSString *)pageDescription thumbUrl:(NSString *)thumbUrl originalUrl:(NSString *)originalUrl contentType:(NSString *)contentType size:(CGSize)size duration:(int32_t)duration {
    self = [super initWithQueryId:(int64_t)queryId resultId:resultId type:type sendMessage:sendMessage];
    if (self != nil) {
        _url = url;
        _displayUrl = displayUrl;
        _title = title;
        _pageDescription = pageDescription;
        _thumbUrl = thumbUrl;
        _originalUrl = originalUrl;
        _contentType = contentType;
        _size = size;
        _duration = duration;
    }
    return self;
}

@end
