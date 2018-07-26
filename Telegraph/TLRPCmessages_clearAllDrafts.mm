#import "TLRPCmessages_clearAllDrafts.h"

#import "TLMetaClassStore.h"

@implementation TLRPCmessages_clearAllDrafts

- (int32_t)TLconstructorSignature
{
    return 0x7e58ee9c;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [NSNumber class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 83;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_clearAllDrafts deserialization not supported");
    return nil;
}

@end
