#import "TLRPCmessages_getInlineBotResults.h"

#import "TL/TLMetaScheme.h"

#import "TLMetaClassStore.h"

//messages.getInlineBotResults flags:# bot:InputUser peer:InputPeer geo_point:flags.0?InputGeoPoint query:string offset:string = messages.BotResults;

@implementation TLRPCmessages_getInlineBotResults

- (int32_t)TLconstructorSignature
{
    return 0x514e999d;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLmessages_BotResults class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 51;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    
    TLMetaClassStore::serializeObject(os, _bot, true);
    
    TLMetaClassStore::serializeObject(os, _peer, true);
    
    if (_flags & (1 << 0)) {
        TLMetaClassStore::serializeObject(os, _geo_point, true);
    }
    
    [os writeString:_query];
    [os writeString:_offset];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_getInlineBotResults deserialization not supported");
    return nil;
}


@end
