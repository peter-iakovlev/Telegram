#import "TGOpenInSignals.h"

#import "TGRemoteHttpLocationSignal.h"
#import "TGSharedMediaSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGOpenInAppItem.h"

NSString *const TGAppStoreEndpointUrl = @"";

@implementation TGOpenInSignals

+ (SSignal *)iconForAppItem:(TGOpenInAppItem *)appItem
{
    CGSize size = CGSizeMake(120, 120);
    NSString *url = [NSString stringWithFormat:@"appIcon:%ld", appItem.storeIdentifier];
    NSString *key = [[NSString alloc] initWithFormat:@"cached-external-image-%@-%dx%d-%@", url, (int)size.width, (int)size.height, @"appIcon"];

    NSString *metaUrl = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%ld", appItem.storeIdentifier];
    
    SSignal *loadImageSignal = [[TGRemoteHttpLocationSignal jsonForHttpLocation:metaUrl] mapToSignal:^SSignal *(id json)
    {
        if (![json respondsToSelector:@selector(objectForKey:)])
            return [SSignal fail:nil];
        
        NSArray *results = json[@"results"];
        if (![results respondsToSelector:@selector(objectAtIndex:)])
            return [SSignal fail:nil];
        
        NSDictionary *result = results.firstObject;
        if (![result respondsToSelector:@selector(objectForKey:)])
            return [SSignal fail:nil];
        
        NSString *artwork = result[@"artworkUrl512"];
        if (artwork.length == 0)
            artwork = result[@"artworkUrl100"];
        
        if (artwork.length == 0)
            return [SSignal fail:nil];
        
        return [TGRemoteHttpLocationSignal dataForHttpLocation:artwork];
    }];
    
    return [TGSharedMediaSignals cachedRemoteThumbnailWithKey:key size:size pixelProcessingBlock:nil fetchData:[SSignal defer:^SSignal *{
        return loadImageSignal;
    }] originalImage:[SSignal fail:nil] threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
    
    return nil;
}

@end
