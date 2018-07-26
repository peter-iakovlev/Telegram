#import "TLStickerSet$stickerSet.h"

#import "TLMetaClassStore.h"

//stickerSet#5585a139 flags:# archived:flags.1?true official:flags.2?true masks:flags.3?true installed_date:flags.0?int id:long access_hash:long title:string short_name:string count:int hash:int = StickerSet;

@implementation TLStickerSet$stickerSet

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLStickerSet$stickerSet serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLStickerSet$stickerSet *result = [[TLStickerSet$stickerSet alloc] init];
    
    result.flags = [is readInt32];
    
    if (result.flags & (1 << 0)) {
        result.installed_date = [is readInt32];
    }
    
    result.n_id = [is readInt64];
    result.access_hash = [is readInt64];
    result.title = [is readString];
    result.short_name = [is readString];
    result.count = [is readInt32];
    result.n_hash = [is readInt32];
    
    return result;
}

@end
