#import "TGCachedStickerPack.h"

@implementation TGCachedStickerPack

- (instancetype)initWithDate:(int32_t)date stickerPack:(TGStickerPack *)stickerPack
{
    self = [super init];
    if (self != nil)
    {
        _date = date;
        _stickerPack = stickerPack;
    }
    return self;
}

@end
