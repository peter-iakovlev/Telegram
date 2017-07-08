#import "TLPhoneCallProtocol.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPhoneCallProtocol


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

@implementation TLPhoneCallProtocol$phoneCallProtocol : TLPhoneCallProtocol


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa2bb35cb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x40cd0b19;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPhoneCallProtocol$phoneCallProtocol *object = [[TLPhoneCallProtocol$phoneCallProtocol alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.min_layer = metaObject->getInt32((int32_t)0xda47b9a9);
    object.max_layer = metaObject->getInt32((int32_t)0x721a222a);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.min_layer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xda47b9a9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_layer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x721a222a, value));
    }
}


@end

