#import "TLphone_PhoneCall.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPhoneCall.h"

@implementation TLphone_PhoneCall


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

@implementation TLphone_PhoneCall$phone_phoneCall : TLphone_PhoneCall


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xec82e140;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6f2d94b4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLphone_PhoneCall$phone_phoneCall *object = [[TLphone_PhoneCall$phone_phoneCall alloc] init];
    object.phone_call = metaObject->getObject((int32_t)0x77bcd691);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.phone_call;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x77bcd691, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

