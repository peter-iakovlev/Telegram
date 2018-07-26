#import "TLRPCmessages_searchStickerSets.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

@implementation TLRPCmessages_searchStickerSets

- (int32_t)TLconstructorSignature
{
    return 0xc2b7d08b;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLmessages_FoundStickerSets class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 76;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    [os writeString:_q];
    [os writeInt32:_n_hash];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_searchStickerSets deserialization not supported");
    return nil;
}

@end
