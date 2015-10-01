#import <SSignalKit/SSignalKit.h>

@class TGDataItem;
@class TGLiveUploadActorData;

@interface TGSendAudioSignal : NSObject

+ (SSignal *)sendAudioWithPeerId:(int64_t)peerId tempDataItem:(TGDataItem *)tempDataItem liveData:(TGLiveUploadActorData *)liveData duration:(int32_t)duration replyToMid:(int32_t)replyToMid;

@end
