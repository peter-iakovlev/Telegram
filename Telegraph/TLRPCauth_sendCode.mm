#import "TLRPCauth_sendCode.h"

#import "TLauth_SentCode.h"

#import "TLMetaClassStore.h"

//auth.sendCode flags:# allow_flashcall:flags.0?true phone_number:string current_number:flags.0?Bool api_id:int api_hash:string lang_code:string = auth.SentCode;

@implementation TLRPCauth_sendCode

- (int32_t)TLconstructorSignature
{
    return 0xccfd70cf;
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
    
    [os writeInt32:_api_id];
    [os writeString:_api_hash];
    [os writeString:_lang_code];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCauth_sendCode deserialization not supported");
    return nil;
}

@end
