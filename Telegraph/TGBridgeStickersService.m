#import "TGBridgeStickersService.h"

#import "TGStickersSignals.h"
#import "TGBridgeStickerPack+TGStickerPack.h"

NSString *const TGBridgeStickersDataFileName = @"stickers.data";
NSString *const TGBridgeStickersSentImagesFileName = @"stickers.imgs";

@interface TGBridgeStickersService ()
{
    SSignal *_stickersSignal;
    SMetaDisposable *_disposable;
}
@end


@implementation TGBridgeStickersService

- (instancetype)initWithServer:(TGBridgeServer *)server
{
    self = [super initWithServer:server];
    if (self != nil)
    {
        _stickersSignal = [[server server] mapToSignal:^SSignal *(TGBridgeServer *server) {
            return [server serviceSignalForKey:@"stickers" producer:^SSignal *{
                return [TGStickersSignals stickerPacks];
            }];
        }];
        
        __weak TGBridgeStickersService *weakSelf = self;
        _disposable = [[SMetaDisposable alloc] init];
        [_disposable setDisposable:[_stickersSignal startWithNext:^(NSDictionary *next)
        {
            __strong TGBridgeStickersService *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            NSArray *stickerPacks = next[@"packs"];
            NSMutableArray *bridgeStickerPacks = [[NSMutableArray alloc] init];
            
            for (TGStickerPack *stickerPack in stickerPacks)
            {
                TGBridgeStickerPack *bridgeStickerPack = [TGBridgeStickerPack stickerPackWithTGStickerPack:stickerPack];
                if (bridgeStickerPack != nil)
                    [bridgeStickerPacks addObject:bridgeStickerPack];
            }
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bridgeStickerPacks];
            NSURL *url = [NSURL URLWithString:TGBridgeStickersDataFileName relativeToURL:strongSelf.server.temporaryFilesURL];
            [data writeToURL:url atomically:true];
            
            [strongSelf.server sendFileWithURL:url metadata:@{ TGBridgeIncomingFileIdentifierKey: @"stickers" }];
        }]];
    }
    return self;
}

@end
