#import "TLmessages_FoundStickerSets.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

@implementation TLmessages_FoundStickerSets

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

@implementation TLmessages_FoundStickerSets$messages_foundStickerSets : TLmessages_FoundStickerSets


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5108d648;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe8a26dde;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_FoundStickerSets$messages_foundStickerSets *object = [[TLmessages_FoundStickerSets$messages_foundStickerSets alloc] init];
    object.n_hash = metaObject->getInt32((int32_t)0xc152e470);
    object.sets = metaObject->getArray((int32_t)0xc535ffc6);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.sets;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc535ffc6, value));
    }
}


@end


