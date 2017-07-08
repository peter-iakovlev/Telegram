#import "TLmessages_SavedGifs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_SavedGifs


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

@implementation TLmessages_SavedGifs$messages_savedGifsNotModified : TLmessages_SavedGifs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe8025ca2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x47a4a839;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLmessages_SavedGifs$messages_savedGifsNotModified *object = [[TLmessages_SavedGifs$messages_savedGifsNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLmessages_SavedGifs$messages_savedGifs : TLmessages_SavedGifs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2e0709a5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3c9b9655;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_SavedGifs$messages_savedGifs *object = [[TLmessages_SavedGifs$messages_savedGifs alloc] init];
    object.n_hash = metaObject->getInt32((int32_t)0xc152e470);
    object.gifs = metaObject->getArray((int32_t)0x2e4314f9);
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
        value.nativeObject = self.gifs;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2e4314f9, value));
    }
}


@end

