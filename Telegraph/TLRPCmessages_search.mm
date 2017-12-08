#import "TLRPCmessages_search.h"

#import "TLMetaClassStore.h"

@implementation TLRPCmessages_search

- (int32_t)TLconstructorSignature
{
    return 0xf288a275;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLmessages_Messages class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 70;
}

//messages.search#f288a275 flags:# peer:InputPeer q:string from_id:flags.0?InputUser filter:MessagesFilter min_date:int max_date:int offset:int max_id:int limit:int = messages.Messages;

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    
    TLMetaClassStore::serializeObject(os, self.peer, true);
    
    [os writeString:self.q];
    
    if (self.flags & (1 << 0)) {
        TLMetaClassStore::serializeObject(os, self.from_id, true);
    }
    
    TLMetaClassStore::serializeObject(os, self.filter, true);
    
    [os writeInt32:self.min_date];
    [os writeInt32:self.max_date];
    [os writeInt32:self.offset];
    [os writeInt32:self.max_id];
    [os writeInt32:self.limit];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    return nil;
}

@end
