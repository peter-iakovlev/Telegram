#import "TLFileLocation.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLFileLocation


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

@implementation TLFileLocation$fileLocationUnavailable : TLFileLocation


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7c596b46;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4182aac;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLFileLocation$fileLocationUnavailable *object = [[TLFileLocation$fileLocationUnavailable alloc] init];
    object.volume_id = metaObject->getInt64((int32_t)0xdfa67416);
    object.local_id = metaObject->getInt32((int32_t)0x1a9ce92a);
    object.secret = metaObject->getInt64((int32_t)0x6706b4b7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.volume_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdfa67416, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.local_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1a9ce92a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.secret;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6706b4b7, value));
    }
}


@end

@implementation TLFileLocation$fileLocation : TLFileLocation


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x53d69076;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa7654e99;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLFileLocation$fileLocation *object = [[TLFileLocation$fileLocation alloc] init];
    object.dc_id = metaObject->getInt32((int32_t)0xae973dc4);
    object.volume_id = metaObject->getInt64((int32_t)0xdfa67416);
    object.local_id = metaObject->getInt32((int32_t)0x1a9ce92a);
    object.secret = metaObject->getInt64((int32_t)0x6706b4b7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.dc_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xae973dc4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.volume_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdfa67416, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.local_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1a9ce92a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.secret;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6706b4b7, value));
    }
}


@end

