#import "TLRPCauth_signIn.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLauth_Authorization.h"

@implementation TLRPCauth_signIn


- (Class)responseClass
{
    return [TLauth_Authorization class];
}

- (int)impliedResponseSignature
{
    return (int)0xb1937d19;
}

- (int)layerVersion
{
    return 8;
}

- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLRPCauth_signIn$auth_signIn : TLRPCauth_signIn


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbcd51581;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc6e76afa;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCauth_signIn$auth_signIn *object = [[TLRPCauth_signIn$auth_signIn alloc] init];
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
    object.phone_code_hash = metaObject->getString((int32_t)0xd4dfef1b);
    object.phone_code = metaObject->getString((int32_t)0xbbf1e711);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_number;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaecb6c79, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd4dfef1b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbbf1e711, value));
    }
}


@end

