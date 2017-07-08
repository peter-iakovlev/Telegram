#import "TLmessages_ArchivedStickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_ArchivedStickers


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

@implementation TLmessages_ArchivedStickers$messages_archivedStickers : TLmessages_ArchivedStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4fcba9c8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3a4e4c46;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_ArchivedStickers$messages_archivedStickers *object = [[TLmessages_ArchivedStickers$messages_archivedStickers alloc] init];
    object.count = metaObject->getInt32((int32_t)0x5fa6aa74);
    object.sets = metaObject->getArray((int32_t)0xc535ffc6);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5fa6aa74, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.sets;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc535ffc6, value));
    }
}


@end

