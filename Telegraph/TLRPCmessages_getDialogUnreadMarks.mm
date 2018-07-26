#import "TLRPCmessages_getDialogUnreadMarks.h"

@implementation TLRPCmessages_getDialogUnreadMarks

- (int32_t)TLconstructorSignature
{
    return 0x22e24e22;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 82;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_getDialogUnreadMarks deserialization not supported");
    return nil;
}

@end
