#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGMessageSearchFilterAny,
    TGMessageSearchFilterPhoto,
    TGMessageSearchFilterVideo,
    TGMessageSearchFilterFile,
    TGMessageSearchFilterAudio,
    TGMessageSearchFilterPhotoVideo,
    TGMessageSearchFilterPhotoVideoFile,
    TGMessageSearchFilterLink
} TGMessageSearchFilter;

@interface TGMessageSearchSignals : NSObject

+ (SSignal *)searchPeer:(int64_t)peer accessHash:(int64_t)accessHash query:(NSString *)query filter:(TGMessageSearchFilter)filter maxMessageId:(int32_t)maxMessageId limit:(NSUInteger)limit;

+ (SSignal *)shareLinkForChannelMessage:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId;

@end
