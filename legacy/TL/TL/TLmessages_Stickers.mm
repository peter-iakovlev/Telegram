#import "TLmessages_Stickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_Stickers


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

@implementation TLmessages_Stickers$messages_stickersNotModified : TLmessages_Stickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf1749a22;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1f8c5fc8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLmessages_Stickers$messages_stickersNotModified *object = [[TLmessages_Stickers$messages_stickersNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLmessages_Stickers$messages_stickers : TLmessages_Stickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8a8ecd32;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4aa7363e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_Stickers$messages_stickers *object = [[TLmessages_Stickers$messages_stickers alloc] init];
    object.n_hash = metaObject->getString((int32_t)0xc152e470);
    object.stickers = metaObject->getArray((int32_t)0x6863de1a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.stickers;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6863de1a, value));
    }
}


@end

