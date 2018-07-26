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


@implementation TGCachedStickers

- (instancetype)initWithHash:(int32_t)stickersHash emoticon:(NSString *)emoticon documents:(NSArray *)documents
{
    self = [super init];
    if (self != nil)
    {
        _stickersHash = stickersHash;
        _emoticon = emoticon;
        _documents = documents;
    }
    return self;
}

@end
