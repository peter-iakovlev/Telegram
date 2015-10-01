#import <Foundation/Foundation.h>

@class TGDataItem;
@class TGLiveUploadActorData;

@interface TGBridgeAudioConverter : NSObject

- (instancetype)initWithURL:(NSURL *)url;
- (void)startWithCompletion:(void (^)(TGDataItem *, int32_t, TGLiveUploadActorData *))completion;

@end
