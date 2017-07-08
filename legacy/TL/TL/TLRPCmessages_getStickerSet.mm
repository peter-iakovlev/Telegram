#import "TLRPCmessages_getStickerSet.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputStickerSet.h"
#import "TLmessages_StickerSet.h"

@implementation TLRPCmessages_getStickerSet


- (Class)responseClass
{
    return [TLmessages_StickerSet class];
}

- (int)impliedResponseSignature
{
    return (int)0xb60a24a6;
}

- (int)layerVersion
{
    return 29;
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

@implementation TLRPCmessages_getStickerSet$messages_getStickerSet : TLRPCmessages_getStickerSet


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2619a90e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf333dc14;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getStickerSet$messages_getStickerSet *object = [[TLRPCmessages_getStickerSet$messages_getStickerSet alloc] init];
    object.stickerset = metaObject->getObject((int32_t)0xaac37694);
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
}


@end

