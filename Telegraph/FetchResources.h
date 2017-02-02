#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "MediaBox.h"
#import "TGTelegramNetworking.h"

#ifdef __cplusplus
extern "C" {
#endif

SSignal *fetchResource(id<MediaResource> resource, NSRange range, TGNetworkMediaTypeTag mediaTypeTag);

#ifdef __cplusplus
}
#endif
