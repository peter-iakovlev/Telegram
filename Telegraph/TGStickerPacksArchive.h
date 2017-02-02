#import <Foundation/Foundation.h>

#import "TGStickerPack.h"
#import "PSCoding.h"

@interface TGStickerPacksArchive : NSObject <PSCoding>

@property (nonatomic, strong) NSArray<TGStickerPack *> *packs;


@end
