#import "TLRPCmessages_getDocumentByHash.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLDocument.h"

@implementation TLRPCmessages_getDocumentByHash


- (Class)responseClass
{
    return [TLDocument class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 44;
}

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

@implementation TLRPCmessages_getDocumentByHash$messages_getDocumentByHash : TLRPCmessages_getDocumentByHash


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x338e2464;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9e7ab9b7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getDocumentByHash$messages_getDocumentByHash *object = [[TLRPCmessages_getDocumentByHash$messages_getDocumentByHash alloc] init];
    object.sha256 = metaObject->getBytes((int32_t)0xcd993c85);
    object.size = metaObject->getInt32((int32_t)0x5a228f5e);
    object.mime_type = metaObject->getString((int32_t)0xcd8e470b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.sha256;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd993c85, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a228f5e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.mime_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd8e470b, value));
    }
}


@end

