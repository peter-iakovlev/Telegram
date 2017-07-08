#import "TLRPCmessages_reorderPinnedDialogs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCmessages_reorderPinnedDialogs


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
    return 61;
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

@implementation TLRPCmessages_reorderPinnedDialogs$messages_reorderPinnedDialogs : TLRPCmessages_reorderPinnedDialogs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x959ff644;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x216dd31f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_reorderPinnedDialogs$messages_reorderPinnedDialogs *object = [[TLRPCmessages_reorderPinnedDialogs$messages_reorderPinnedDialogs alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.order = metaObject->getArray((int32_t)0x40fe6817);
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
        value.nativeObject = self.order;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x40fe6817, value));
    }
}


@end

