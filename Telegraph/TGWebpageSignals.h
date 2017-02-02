#import <SSignalKit/SSignalKit.h>

@class TGWebPageMediaAttachment;

@interface TGWebpageSignals : NSObject

+ (SSignal *)webpagePreview:(NSString *)url;
+ (SSignal *)updatedWebpage:(TGWebPageMediaAttachment *)webPage;
+ (SSignal *)cachedOrRemoteWebpage:(int64_t)webPageId url:(NSString *)url;

@end
