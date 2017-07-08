#import "TLRPCmessages_searchGlobal.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"
#import "TLmessages_Messages.h"

@implementation TLRPCmessages_searchGlobal


- (Class)responseClass
{
    return [TLmessages_Messages class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 41;
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

@implementation TLRPCmessages_searchGlobal$messages_searchGlobal : TLRPCmessages_searchGlobal


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9e3cacb0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x43461509;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_searchGlobal$messages_searchGlobal *object = [[TLRPCmessages_searchGlobal$messages_searchGlobal alloc] init];
    object.q = metaObject->getString((int32_t)0xcd45cb1c);
    object.offset_date = metaObject->getInt32((int32_t)0xe37adfc2);
    object.offset_peer = metaObject->getObject((int32_t)0xfcfce48f);
    object.offset_id = metaObject->getInt32((int32_t)0x1120a8cd);
    object.limit = metaObject->getInt32((int32_t)0xb8433fca);
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
        value.primitive.int32Value = self.offset_date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe37adfc2, value));
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
        value.primitive.int32Value = self.offset_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1120a8cd, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8433fca, value));
    }
}


@end

