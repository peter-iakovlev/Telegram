#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGStickerPack.h>

@interface TGStickerPacksArchive : NSObject <PSCoding>

@property (nonatomic, strong) NSArray<TGStickerPack *> *packs;


@end
