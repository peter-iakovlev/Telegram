#import "TLRPCaccount_sendVerifyPhoneCode.h"

#import "TLMetaClassStore.h"

@implementation TLRPCaccount_sendVerifyPhoneCode

- (int32_t)TLconstructorSignature
{
    return 0x823380b4;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLauth_SentCode class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 78;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    
    [os writeString:_phone_number];
    
    if (_flags & (1 << 0)) {
        if (_current_number) {
            [os writeInt32:TL_BOOL_TRUE_CONSTRUCTOR];
        } else {
            [os writeInt32:TL_BOOL_FALSE_CONSTRUCTOR];
        }
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_sendVerifyPhoneCode deserialization not supported");
    return nil;
}

@end
