#import "TLRPCmessages_saveGif.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputDocument.h"

@implementation TLRPCmessages_saveGif


- (Class)responseClass
{
    return [NSNumber class];
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

@implementation TLRPCmessages_saveGif$messages_saveGif : TLRPCmessages_saveGif


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x327a30cb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x23635cd6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_saveGif$messages_saveGif *object = [[TLRPCmessages_saveGif$messages_saveGif alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    object.unsave = metaObject->getBool((int32_t)0xb4a6ae0c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.unsave;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb4a6ae0c, value));
    }
}


@end

