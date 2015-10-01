#import "TLRPCmessages_installStickerSet.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputStickerSet.h"

@implementation TLRPCmessages_installStickerSet


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
    return 32;
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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLRPCmessages_installStickerSet$messages_installStickerSet : TLRPCmessages_installStickerSet


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7b30c3a6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x76680a3c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_installStickerSet$messages_installStickerSet *object = [[TLRPCmessages_installStickerSet$messages_installStickerSet alloc] init];
    object.stickerset = metaObject->getObject((int32_t)0xaac37694);
    object.disabled = metaObject->getBool((int32_t)0x39e317f);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.stickerset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaac37694, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.disabled;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x39e317f, value));
    }
}


@end

