#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

@interface TGCachedStickerPack : NSObject

@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) TGStickerPack *stickerPack;

- (instancetype)initWithDate:(int32_t)date stickerPack:(TGStickerPack *)stickerPack;

@end


@interface TGCachedStickers : NSObject

@property (nonatomic, readonly) int32_t stickersHash;
@property (nonatomic, readonly) NSString *emoticon;
@property (nonatomic, readonly) NSArray *documents;

- (instancetype)initWithHash:(int32_t)stickersHash emoticon:(NSString *)emoticon documents:(NSArray *)documents;

@end
