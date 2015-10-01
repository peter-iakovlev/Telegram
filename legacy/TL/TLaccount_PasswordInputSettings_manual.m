#import "TLaccount_PasswordInputSettings_manual.h"

#import "TGStringUtils.h"

@implementation TLaccount_PasswordInputSettings_manual

- (int32_t)TLconstructorName
{
    return -1;
}

- (int32_t)TLconstructorSignature
{
    return (int32_t)-1124314324;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    
    if (_flags & (1 << 0))
    {
        [os writeBytes:_n_newSalt];
        [os writeBytes:_n_newPasswordHash];
        [os writeString:_hint];
    }
    
    if (_flags & (1 << 1))
    {
        [os writeString:_email];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLaccount_PasswordInputSettings_manual deserialization not supported");
    return nil;
}

@end
