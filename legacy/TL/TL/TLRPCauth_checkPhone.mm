#import "TLRPCauth_checkPhone.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLauth_CheckedPhone.h"

@implementation TLRPCauth_checkPhone


- (Class)responseClass
{
    return [TLauth_CheckedPhone class];
}

- (int)impliedResponseSignature
{
    return (int)0x811ea28e;
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

@implementation TLRPCauth_checkPhone$auth_checkPhone : TLRPCauth_checkPhone


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6fe51dfb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x69bacaad;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCauth_checkPhone$auth_checkPhone *object = [[TLRPCauth_checkPhone$auth_checkPhone alloc] init];
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
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
}


@end

