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

@end
