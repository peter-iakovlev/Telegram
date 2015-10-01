#import "TGBridgeStickersSignals.h"
#import "TGBridgeStickersSubscription.h"
#import "TGBridgeResponse.h"
#import "TGBridgeStickerPack.h"
#import "TGBridgeDocumentMediaAttachment.h"
#import "TGBridgeClient.h"

@implementation TGBridgeStickersSignals

+ (SSignal *)recentStickersWithLimit:(NSUInteger)limit
{
    return [[TGBridgeClient instance] requestSignalWithSubscription:[[TGBridgeRecentStickersSubscription alloc] initWithLimit:limit]];
}

static NSArray *stickerPacks = nil;

+ (SSignal *)stickerPacks
{
    return [[SSignal single:[[TGBridgeClient instance] stickerPacks]] then:[[TGBridgeClient instance] fileSignalForKey:@"stickers"]];
}

+ (NSURL *)stickerPacksURL
{
    static dispatch_once_t onceToken;
    static NSURL *stickerPacksURL;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
        stickerPacksURL = [[NSURL alloc] initFileURLWithPath:[documentsPath stringByAppendingPathComponent:@"stickers.data"]];
    });
    return stickerPacksURL;
}

@end
