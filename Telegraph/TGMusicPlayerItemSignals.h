#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGMusicPlayerItem.h"

typedef struct {
    bool downloaded;
    bool downloading;
    CGFloat progress;
} TGMusicPlayerItemAvailability;

#ifdef __cplusplus
extern "C" {
#endif
    
TGMusicPlayerItemAvailability TGMusicPlayerItemAvailabilityUnpack(int64_t value);
    
#ifdef __cplusplus
}
#endif

@interface TGMusicPlayerItemSignals : NSObject

+ (NSString *)pathForItem:(TGMusicPlayerItem *)item;

+ (SSignal *)itemAvailability:(TGMusicPlayerItem *)item priority:(bool)priority;

@end
