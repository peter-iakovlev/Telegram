#import "FetchResources.h"

#import "TelegramMediaResources.h"
#import "MultipartFetch.h"
#import "TGRemoteImageView.h"

SSignal *fetchResource(id<MediaResource> resource, NSRange range, TGNetworkMediaTypeTag mediaTypeTag) {
    if ([resource conformsToProtocol:@protocol(TelegramCloudMediaResource)]) {
        id<TelegramCloudMediaResource> cloudResource = (id<TelegramCloudMediaResource>)resource;
        if ([resource isKindOfClass:[CloudFileMediaResource class]]) {
            CloudFileMediaResource *cloudFile = (CloudFileMediaResource *)cloudResource;
            if (cloudFile.legacyCacheUrl != nil) {
                NSString *legacyPath = [[TGRemoteImageView sharedCache] pathForCachedData:cloudFile.legacyCacheUrl];
                NSData *data = [[NSData alloc] initWithContentsOfFile:legacyPath];
                if (data != nil) {
                    return [SSignal single:[[MediaResourceDataFetchResult alloc] initWithData:data complete:true]];
                }
            }
            if (cloudFile.legacyCachePath != nil) {
                NSData *data = [[NSData alloc] initWithContentsOfFile:cloudFile.legacyCachePath];
                if (data != nil) {
                    return [SSignal single:[[MediaResourceDataFetchResult alloc] initWithData:data complete:true]];
                }
            }
        }
        return multipartFetch(cloudResource, [cloudResource size], range, mediaTypeTag);
    } else {
        return [SSignal never];
    }
}
