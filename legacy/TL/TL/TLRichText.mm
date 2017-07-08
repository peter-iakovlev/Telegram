#import "TLRichText.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLRichText.h"

@implementation TLRichText


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

@implementation TLRichText$textEmpty : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xdc3d824f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x161255a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRichText$textEmpty *object = [[TLRichText$textEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLRichText$textPlain : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x744694e0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbc9c9c54;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textPlain *object = [[TLRichText$textPlain alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLRichText$textBold : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6724abc4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa8b7999d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textBold *object = [[TLRichText$textBold alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLRichText$textItalic : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd912a59c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x83a88724;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textItalic *object = [[TLRichText$textItalic alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLRichText$textUnderline : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc12622c4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbd3ac160;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textUnderline *object = [[TLRichText$textUnderline alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLRichText$textStrike : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9bf8bb95;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x91885697;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textStrike *object = [[TLRichText$textStrike alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLRichText$textFixed : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6c3f19b9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8ecfe758;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textFixed *object = [[TLRichText$textFixed alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLRichText$textUrl : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3c2884c1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe0e8b8d3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textUrl *object = [[TLRichText$textUrl alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.webpage_id = metaObject->getInt64((int32_t)0xcf81f3f);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.webpage_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcf81f3f, value));
    }
}


@end

@implementation TLRichText$textEmail : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xde5a0dd6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe5503523;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textEmail *object = [[TLRichText$textEmail alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    object.email = metaObject->getString((int32_t)0x5b2095e7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.email;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b2095e7, value));
    }
}


@end

@implementation TLRichText$textConcat : TLRichText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7e6260d7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe17b82e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRichText$textConcat *object = [[TLRichText$textConcat alloc] init];
    object.texts = metaObject->getArray((int32_t)0x8c957ffa);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.texts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8c957ffa, value));
    }
}


@end

