#import "TLRPCmessages_deleteMessages.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_AffectedMessages.h"

@implementation TLRPCmessages_deleteMessages


- (Class)responseClass
{
    return [TLmessages_AffectedMessages class];
}

- (int)impliedResponseSignature
{
    return (int)0x84d19185;
}

- (int)layerVersion
{
    return 62;
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

@implementation TLRPCmessages_deleteMessages$messages_deleteMessages : TLRPCmessages_deleteMessages


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe58e95d2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x734e21b8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_deleteMessages$messages_deleteMessages *object = [[TLRPCmessages_deleteMessages$messages_deleteMessages alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.n_id = metaObject->getArray((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

