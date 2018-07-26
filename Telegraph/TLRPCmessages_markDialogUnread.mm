#import "TLRPCmessages_markDialogUnread.h"

#import "TLMetaClassStore.h"

@implementation TLRPCmessages_markDialogUnread

- (int32_t)TLconstructorSignature
{
    return 0xc286d98f;
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
    return 82;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    TLMetaClassStore::serializeObject(os, self.peer, true);
    
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_markDialogUnread deserialization not supported");
    return nil;
}

@end
