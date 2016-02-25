#import "TLchannels_MessageEditData$messageEditData.h"

#import "TLMetaClassStore.h"

//channels.messageEditData flags:# caption:flags.1?true from_id:int edit_by:flags.0?int edit_date:flags.0?int users:Vector<User> = channels.MessageEditData;

@implementation TLchannels_MessageEditData$messageEditData

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLchannels_MessageEditData$messageEditData serialization not supported");
}

- (bool)caption {
    return _flags & (1 << 1);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLchannels_MessageEditData$messageEditData *result = [[TLchannels_MessageEditData$messageEditData alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    return result;
}

@end
