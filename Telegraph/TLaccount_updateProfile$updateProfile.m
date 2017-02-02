#import "TLaccount_updateProfile$updateProfile.h"

#import "TLUser.h"

//account.updateProfile flags:# first_name:flags.0?string last_name:flags.1?string about:flags.2?string = User;

@implementation TLaccount_updateProfile$updateProfile

- (int32_t)TLconstructorSignature
{
    return 0x78515775;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLUser class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 49;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    
    if (_flags & (1 << 0)) {
        [os writeString:_first_name];
    }
    
    if (_flags & (1 << 1)) {
        [os writeString:_last_name];
    }
    
    if (_flags & (1 << 2)) {
        [os writeString:_about];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLaccount_updateProfile$updateProfile deserialization not supported");
    return nil;
}

@end
