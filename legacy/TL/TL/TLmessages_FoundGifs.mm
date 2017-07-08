#import "TLmessages_FoundGifs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_FoundGifs


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

@implementation TLmessages_FoundGifs$messages_foundGifs : TLmessages_FoundGifs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x450a1c0a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x960b3289;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_FoundGifs$messages_foundGifs *object = [[TLmessages_FoundGifs$messages_foundGifs alloc] init];
    object.next_offset = metaObject->getInt32((int32_t)0x873f1f36);
    object.results = metaObject->getArray((int32_t)0x817bffcc);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.next_offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x873f1f36, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.results;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x817bffcc, value));
    }
}


@end

