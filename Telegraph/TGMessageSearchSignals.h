#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGMessageSearchFilterAny,
    TGMessageSearchFilterPhoto,
    TGMessageSearchFilterVideo,
    TGMessageSearchFilterFile,
    TGMessageSearchFilterAudio,
    TGMessageSearchFilterPhotoVideo,
    TGMessageSearchFilterPhotoVideoFile,
    TGMessageSearchFilterLink,
    TGMessageSearchFilterGroupPhotos,
    TGMessageSearchFilterPhoneCalls,
    TGMessageSearchFilterVoiceRound
} TGMessageSearchFilter;

@interface TGMessageSearchSignals : NSObject

+ (SSignal *)searchPeer:(int64_t)peer accessHash:(int64_t)accessHash query:(NSString *)query filter:(TGMessageSearchFilter)filter maxMessageId:(int32_t)maxMessageId limit:(NSUInteger)limit;
+ (SSignal *)searchPeer:(int64_t)peer accessHash:(int64_t)accessHash query:(NSString *)query filter:(TGMessageSearchFilter)filter maxMessageId:(int32_t)maxMessageId limit:(NSUInteger)limit around:(bool)around;

+ (SSignal *)shareLinkForChannelMessage:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId;

+ (SSignal *)messageIdForPeerId:(int64_t)peerId date:(int32_t)date;

@end
