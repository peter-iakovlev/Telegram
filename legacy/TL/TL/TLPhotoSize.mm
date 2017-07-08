#import "TLPhotoSize.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLFileLocation.h"

@implementation TLPhotoSize


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

@implementation TLPhotoSize$photoSizeEmpty : TLPhotoSize


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe17e23c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1561e8e7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPhotoSize$photoSizeEmpty *object = [[TLPhotoSize$photoSizeEmpty alloc] init];
    object.type = metaObject->getString((int32_t)0x9211ab0a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
}


@end

@implementation TLPhotoSize$photoSize : TLPhotoSize


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x77bfb61b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2585930b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPhotoSize$photoSize *object = [[TLPhotoSize$photoSize alloc] init];
    object.type = metaObject->getString((int32_t)0x9211ab0a);
    object.location = metaObject->getObject((int32_t)0x504a1f06);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    object.size = metaObject->getInt32((int32_t)0x5a228f5e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.location;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x504a1f06, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.w;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x98407fc3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.h;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x27243f49, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a228f5e, value));
    }
}


@end

@implementation TLPhotoSize$photoCachedSize : TLPhotoSize


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe9a734fa;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa80b2929;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPhotoSize$photoCachedSize *object = [[TLPhotoSize$photoCachedSize alloc] init];
    object.type = metaObject->getString((int32_t)0x9211ab0a);
    object.location = metaObject->getObject((int32_t)0x504a1f06);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    object.bytes = metaObject->getBytes((int32_t)0xec5ef20a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.location;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x504a1f06, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.w;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x98407fc3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.h;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x27243f49, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xec5ef20a, value));
    }
}


@end

