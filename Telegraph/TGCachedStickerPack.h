#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

@interface TGCachedStickerPack : NSObject

@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) TGStickerPack *stickerPack;

- (instancetype)initWithDate:(int32_t)date stickerPack:(TGStickerPack *)stickerPack;

@end
