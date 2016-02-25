#import <Foundation/Foundation.h>

@interface TGBridgeAudioDecoder : NSObject

- (instancetype)initWithURL:(NSURL *)url;
- (void)startWithCompletion:(void (^)(NSURL *result))completion;
- (void)stop;

@end
