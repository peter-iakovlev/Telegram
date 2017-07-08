#import "TLWallPaper.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLWallPaper


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

@implementation TLWallPaper$wallPaper : TLWallPaper


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xccb03657;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x29cac8ce;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLWallPaper$wallPaper *object = [[TLWallPaper$wallPaper alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.sizes = metaObject->getArray((int32_t)0x7b4ec65f);
    object.color = metaObject->getInt32((int32_t)0xaee6bad0);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.sizes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7b4ec65f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.color;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaee6bad0, value));
    }
}


@end

@implementation TLWallPaper$wallPaperSolid : TLWallPaper


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x63117f24;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x77a94375;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLWallPaper$wallPaperSolid *object = [[TLWallPaper$wallPaperSolid alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.bg_color = metaObject->getInt32((int32_t)0xa262f32b);
    object.color = metaObject->getInt32((int32_t)0xaee6bad0);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bg_color;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa262f32b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.color;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaee6bad0, value));
    }
}


@end

