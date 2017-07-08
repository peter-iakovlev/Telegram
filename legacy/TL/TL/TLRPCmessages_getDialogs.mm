#import "TLRPCmessages_getDialogs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"
#import "TLmessages_Dialogs.h"

@implementation TLRPCmessages_getDialogs


- (Class)responseClass
{
    return [TLmessages_Dialogs class];
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

@implementation TLRPCmessages_getDialogs$messages_getDialogs : TLRPCmessages_getDialogs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x191ba9c5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x91f2a746;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getDialogs$messages_getDialogs *object = [[TLRPCmessages_getDialogs$messages_getDialogs alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.offset_date = metaObject->getInt32((int32_t)0xe37adfc2);
    object.offset_id = metaObject->getInt32((int32_t)0x1120a8cd);
    object.offset_peer = metaObject->getObject((int32_t)0xfcfce48f);
    object.limit = metaObject->getInt32((int32_t)0xb8433fca);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset_date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe37adfc2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1120a8cd, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.offset_peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfcfce48f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8433fca, value));
    }
}


@end

