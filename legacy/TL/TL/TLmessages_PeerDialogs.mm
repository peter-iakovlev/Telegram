#import "TLmessages_PeerDialogs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLupdates_State.h"

@implementation TLmessages_PeerDialogs


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

@implementation TLmessages_PeerDialogs$messages_peerDialogs : TLmessages_PeerDialogs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3371c354;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xad5ec18b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_PeerDialogs$messages_peerDialogs *object = [[TLmessages_PeerDialogs$messages_peerDialogs alloc] init];
    object.dialogs = metaObject->getArray((int32_t)0x708be67);
    object.messages = metaObject->getArray((int32_t)0x8c97b94f);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    object.state = metaObject->getObject((int32_t)0x449b9b4e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.dialogs;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x708be67, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.chats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4240ad02, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.state;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x449b9b4e, value));
    }
}


@end

