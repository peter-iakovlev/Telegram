#import "TLRPCmessages_uninstallStickerSet.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputStickerSet.h"

@implementation TLRPCmessages_uninstallStickerSet


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

@implementation TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet : TLRPCmessages_uninstallStickerSet


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf96e55de;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa74a7ebb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet *object = [[TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet alloc] init];
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

