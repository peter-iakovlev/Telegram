#import "TLphone_DiscardedCall.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUpdates.h"

@implementation TLphone_DiscardedCall


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

@implementation TLphone_DiscardedCall$phone_discardedCall : TLphone_DiscardedCall


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd834f14e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc2ab858b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLphone_DiscardedCall$phone_discardedCall *object = [[TLphone_DiscardedCall$phone_discardedCall alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.updates = metaObject->getObject((int32_t)0x9ae046f4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.updates;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ae046f4, value));
    }
}


@end

