#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputStickerSet : NSObject <TLObject>


@end

@interface TLInputStickerSet$inputStickerSetEmpty : TLInputStickerSet


@end

@interface TLInputStickerSet$inputStickerSetID : TLInputStickerSet

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputStickerSet$inputStickerSetShortName : TLInputStickerSet

@property (nonatomic, retain) NSString *short_name;

@end

