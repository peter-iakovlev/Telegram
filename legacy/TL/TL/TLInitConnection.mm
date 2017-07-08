#import "TLInitConnection.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInitConnection


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

@implementation TLInitConnection$initConnection : TLInitConnection


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x69796de9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfe10095a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInitConnection$initConnection *object = [[TLInitConnection$initConnection alloc] init];
    object.api_id = metaObject->getInt32((int32_t)0x658ffe92);
    object.device_model = metaObject->getString((int32_t)0x7baba117);
    object.system_version = metaObject->getString((int32_t)0x18665337);
    object.app_version = metaObject->getString((int32_t)0xe92d4c10);
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
    object.query = metaObject->getObject((int32_t)0x5de9dcb1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.api_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x658ffe92, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.device_model;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7baba117, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.system_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18665337, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.app_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe92d4c10, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.lang_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2ccfcaf3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.query;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5de9dcb1, value));
    }
}


@end

