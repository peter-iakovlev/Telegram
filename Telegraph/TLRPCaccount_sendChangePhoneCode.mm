#import "TLRPCaccount_sendChangePhoneCode.h"

#import "TLMetaClassStore.h"

//account.sendChangePhoneCode flags:# allow_flashcall:flags.0?true phone_number:string current_number:flags.0?Bool = auth.SentCode

@implementation TLRPCaccount_sendChangePhoneCode

- (int32_t)TLconstructorSignature
{
    return 0x8e57deb;
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
    return 50;
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
    TGLog(@"***** account.sendChangePhoneCode deserialization not supported");
    return nil;
}

@end
