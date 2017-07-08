#import "TLRPCmessages_getAttachedStickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputStickeredMedia.h"
#import "NSArray_StickerSetCovered.h"

@implementation TLRPCmessages_getAttachedStickers


- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return (int)0x5ccdb726;
}

- (int)layerVersion
{
    return 56;
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

@implementation TLRPCmessages_getAttachedStickers$messages_getAttachedStickers : TLRPCmessages_getAttachedStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcc5b67cc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbcb4fbc5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getAttachedStickers$messages_getAttachedStickers *object = [[TLRPCmessages_getAttachedStickers$messages_getAttachedStickers alloc] init];
    object.media = metaObject->getObject((int32_t)0x598de2e7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.media;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x598de2e7, value));
    }
}


@end

