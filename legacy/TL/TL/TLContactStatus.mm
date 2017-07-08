#import "TLContactStatus.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUserStatus.h"

@implementation TLContactStatus


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

@implementation TLContactStatus$contactStatus : TLContactStatus


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd3680c61;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x86ca4966;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLContactStatus$contactStatus *object = [[TLContactStatus$contactStatus alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.status = metaObject->getObject((int32_t)0xab757700);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.status;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xab757700, value));
    }
}


@end

