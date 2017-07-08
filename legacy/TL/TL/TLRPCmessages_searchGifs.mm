#import "TLRPCmessages_searchGifs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_FoundGifs.h"

@implementation TLRPCmessages_searchGifs


- (Class)responseClass
{
    return [TLmessages_FoundGifs class];
}

- (int)impliedResponseSignature
{
    return (int)0x450a1c0a;
}

- (int)layerVersion
{
    return 44;
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

@implementation TLRPCmessages_searchGifs$messages_searchGifs : TLRPCmessages_searchGifs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbf9a776b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x438d6970;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_searchGifs$messages_searchGifs *object = [[TLRPCmessages_searchGifs$messages_searchGifs alloc] init];
    object.q = metaObject->getString((int32_t)0xcd45cb1c);
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd45cb1c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
}


@end

