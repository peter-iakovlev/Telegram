#import "TLauth_CheckedPhone.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLauth_CheckedPhone


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

@implementation TLauth_CheckedPhone$auth_checkedPhone : TLauth_CheckedPhone


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x811ea28e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9eebac54;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_CheckedPhone$auth_checkedPhone *object = [[TLauth_CheckedPhone$auth_checkedPhone alloc] init];
    object.phone_registered = metaObject->getBool((int32_t)0xd2179e1d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.phone_registered;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2179e1d, value));
    }
}


@end

