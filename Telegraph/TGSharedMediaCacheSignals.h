#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGSharedMediaCacheItemTypePhoto = 0,
    TGSharedMediaCacheItemTypeVideo = 1,
    TGSharedMediaCacheItemTypeFile = 2,
    TGSharedMediaCacheItemTypePhotoVideo = 3,
    TGSharedMediaCacheItemTypePhotoVideoFile = 4,
    TGSharedMediaCacheItemTypeAudio = 5,
    TGSharedMediaCacheItemTypeLink = 6
} TGSharedMediaCacheItemType;

@interface TGSharedMediaCacheSignals : NSObject

+ (SSignal *)cachedMediaForPeerId:(int64_t)peerId itemType:(TGSharedMediaCacheItemType)itemType important:(bool)important;

@end
