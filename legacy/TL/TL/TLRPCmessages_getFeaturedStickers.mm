#import "TLRPCmessages_getFeaturedStickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_FeaturedStickers.h"

@implementation TLRPCmessages_getFeaturedStickers


- (Class)responseClass
{
    return [TLmessages_FeaturedStickers class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 54;
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

@implementation TLRPCmessages_getFeaturedStickers$messages_getFeaturedStickers : TLRPCmessages_getFeaturedStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2dacca4f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9741cc6f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getFeaturedStickers$messages_getFeaturedStickers *object = [[TLRPCmessages_getFeaturedStickers$messages_getFeaturedStickers alloc] init];
    object.n_hash = metaObject->getInt32((int32_t)0xc152e470);
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
}


@end

