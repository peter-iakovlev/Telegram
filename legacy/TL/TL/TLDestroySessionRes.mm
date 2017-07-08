#import "TLDestroySessionRes.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDestroySessionRes


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

@implementation TLDestroySessionRes$destroy_session_ok : TLDestroySessionRes


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe22045fc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbcf984a4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDestroySessionRes$destroy_session_ok *object = [[TLDestroySessionRes$destroy_session_ok alloc] init];
    object.session_id = metaObject->getInt64((int32_t)0xacf0d2dd);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.session_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xacf0d2dd, value));
    }
}


@end

@implementation TLDestroySessionRes$destroy_session_none : TLDestroySessionRes


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x62d350c9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcc6b35fe;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDestroySessionRes$destroy_session_none *object = [[TLDestroySessionRes$destroy_session_none alloc] init];
    object.session_id = metaObject->getInt64((int32_t)0xacf0d2dd);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.session_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xacf0d2dd, value));
    }
}


@end

