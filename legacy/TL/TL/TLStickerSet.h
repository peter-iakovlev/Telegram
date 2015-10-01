#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLStickerSet : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *short_name;
@property (nonatomic) int32_t count;
@property (nonatomic) int32_t n_hash;

@end

@interface TLStickerSet$stickerSet : TLStickerSet


@end

