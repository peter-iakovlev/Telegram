#import "TLInputFile.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputFile


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

@implementation TLInputFile$inputFile : TLInputFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf52ff27f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6e120a40;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputFile$inputFile *object = [[TLInputFile$inputFile alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.parts = metaObject->getInt32((int32_t)0xd88278ed);
    object.name = metaObject->getString((int32_t)0x798b364a);
    object.md5_checksum = metaObject->getString((int32_t)0x48bc9943);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.parts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd88278ed, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x798b364a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.md5_checksum;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x48bc9943, value));
    }
}


@end

@implementation TLInputFile$inputFileBig : TLInputFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfa4f0bb5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdef02630;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputFile$inputFileBig *object = [[TLInputFile$inputFileBig alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.parts = metaObject->getInt32((int32_t)0xd88278ed);
    object.name = metaObject->getString((int32_t)0x798b364a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.parts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd88278ed, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x798b364a, value));
    }
}


@end

