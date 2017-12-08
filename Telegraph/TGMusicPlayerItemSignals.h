#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGMusicPlayerItem.h"

@class TGDocumentMediaAttachment;

typedef struct {
    bool downloaded;
    bool downloading;
    CGFloat progress;
} TGMusicPlayerItemAvailability;

#ifdef __cplusplus
extern "C" {
#endif
    
TGMusicPlayerItemAvailability TGMusicPlayerItemAvailabilityUnpack(int64_t value);
NSString *cacheKeyForDocument(TGDocumentMediaAttachment *document);
    
#ifdef __cplusplus
}
#endif

@interface TGMusicPlayerItemSignals : NSObject

+ (NSString *)pathForItem:(TGMusicPlayerItem *)item;

+ (SSignal *)itemAvailability:(TGMusicPlayerItem *)item priority:(bool)priority;

+ (SSignal *)albumArtForItem:(TGMusicPlayerItem *)item thumbnail:(bool)thumbnail;
+ (SSignal *)albumArtForDocument:(TGDocumentMediaAttachment *)document messageId:(int32_t)messageId thumbnail:(bool)thumbnail;

+ (SSignal *)_albumArtSyncForUrl:(NSURL *)url;
+ (SSignal *)_albumArtForUrl:(NSURL *)url multicastManager:(SMulticastSignalManager *)__unused multicastManager;

@end
