#import "TLFutureSalt.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLFutureSalt


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

@implementation TLFutureSalt$futureSalt : TLFutureSalt


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x949d9dc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7c12a91a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLFutureSalt$futureSalt *object = [[TLFutureSalt$futureSalt alloc] init];
    object.valid_since = metaObject->getInt32((int32_t)0xe0edebd2);
    object.valid_until = metaObject->getInt32((int32_t)0x46f4d603);
    object.salt = metaObject->getInt64((int32_t)0x9cda6869);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.valid_since;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe0edebd2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.valid_until;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x46f4d603, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9cda6869, value));
    }
}


@end

