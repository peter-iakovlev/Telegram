#import "TLRPCauth_cancelCode.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCauth_cancelCode


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
    return 50;
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

@implementation TLRPCauth_cancelCode$auth_cancelCode : TLRPCauth_cancelCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1f040578;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2f5b84ff;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCauth_cancelCode$auth_cancelCode *object = [[TLRPCauth_cancelCode$auth_cancelCode alloc] init];
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
    object.phone_code_hash = metaObject->getString((int32_t)0xd4dfef1b);
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
}


@end

