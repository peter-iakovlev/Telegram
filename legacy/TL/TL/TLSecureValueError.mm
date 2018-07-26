#import "TLSecureValueError.h"

@implementation TLSecureValueError

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

@implementation TLSecureValueError$secureValueErrorData : TLSecureValueError

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe8a40bd9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x339b5df7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureValueError$secureValueErrorData *object = [[TLSecureValueError$secureValueErrorData alloc] init];
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
    object.data_hash = metaObject->getBytes((int32_t)0x6f8539a2);
    object.field = metaObject->getString((int32_t)0xd19fb7c4);
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.data_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6f8539a2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.field;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd19fb7c4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLSecureValueError$secureValueErrorFrontSide : TLSecureValueError

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbe3dfa;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x21060bf9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureValueError$secureValueErrorFrontSide *object = [[TLSecureValueError$secureValueErrorFrontSide alloc] init];
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
    object.file_hash = metaObject->getBytes((int32_t)0xde1902e1);
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.file_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xde1902e1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLSecureValueError$secureValueErrorReverseSide : TLSecureValueError

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x868a2aa5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1d0d63e2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureValueError$secureValueErrorReverseSide *object = [[TLSecureValueError$secureValueErrorReverseSide alloc] init];
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
    object.file_hash = metaObject->getBytes((int32_t)0xde1902e1);
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.file_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xde1902e1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLSecureValueError$secureValueErrorSelfie : TLSecureValueError

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe537ced6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x11460082;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureValueError$secureValueErrorSelfie *object = [[TLSecureValueError$secureValueErrorSelfie alloc] init];
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
    object.file_hash = metaObject->getBytes((int32_t)0xde1902e1);
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.file_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xde1902e1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLSecureValueError$secureValueErrorFile : TLSecureValueError

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7a700873;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x380c9c66;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureValueError$secureValueErrorFile *object = [[TLSecureValueError$secureValueErrorFile alloc] init];
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
    object.file_hash = metaObject->getBytes((int32_t)0xde1902e1);
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.file_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xde1902e1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLSecureValueError$secureValueErrorFiles : TLSecureValueError

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x666220e9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x607c2fed;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureValueError$secureValueErrorFiles *object = [[TLSecureValueError$secureValueErrorFiles alloc] init];
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
    object.file_hash = metaObject->getArray((int32_t)0xde1902e1);
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.file_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xde1902e1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end
