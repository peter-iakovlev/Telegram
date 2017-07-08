#import "TLContactSuggested.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLContactSuggested


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

@implementation TLContactSuggested$contactSuggested : TLContactSuggested


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3de191a1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x22bbd6f9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLContactSuggested$contactSuggested *object = [[TLContactSuggested$contactSuggested alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.mutual_contacts = metaObject->getInt32((int32_t)0xc8ba8f61);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.mutual_contacts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc8ba8f61, value));
    }
}


@end

