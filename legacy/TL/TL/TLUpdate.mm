#import "TLUpdate.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChatParticipants.h"
#import "TLUserStatus.h"
#import "TLPhoneCall.h"
#import "TLPhoneConnection.h"
#import "TLUserProfilePhoto.h"
#import "TLEncryptedMessage.h"
#import "TLEncryptedChat.h"
#import "TLNotifyPeer.h"
#import "TLPeerNotifySettings.h"
#import "TLSendMessageAction.h"
#import "TLMessageMedia.h"
#import "TLPrivacyKey.h"
#import "TLMessage.h"
#import "TLPeer.h"
#import "TLContactLink.h"
#import "TLWebPage.h"
#import "TLMessageGroup.h"

@implementation TLUpdate


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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLUpdate$updateMessageID : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4e90bfd6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfbcd22b5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateMessageID *object = [[TLUpdate$updateMessageID alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.random_id = metaObject->getInt64((int32_t)0xca5a160a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xca5a160a, value));
    }
}


@end

@implementation TLUpdate$updateRestoreMessages : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd15de04d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8c21e474;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateRestoreMessages *object = [[TLUpdate$updateRestoreMessages alloc] init];
    object.messages = metaObject->getArray((int32_t)0x8c97b94f);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
}


@end

@implementation TLUpdate$updateChatParticipants : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7761198;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcc141a77;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChatParticipants *object = [[TLUpdate$updateChatParticipants alloc] init];
    object.participants = metaObject->getObject((int32_t)0xe0e25c28);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.participants;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe0e25c28, value));
    }
}


@end

@implementation TLUpdate$updateUserStatus : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1bfbd823;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x48b263c8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserStatus *object = [[TLUpdate$updateUserStatus alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.status = metaObject->getObject((int32_t)0xab757700);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.status;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xab757700, value));
    }
}


@end

@implementation TLUpdate$updateContactRegistered : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2575bbb9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa8b24c75;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateContactRegistered *object = [[TLUpdate$updateContactRegistered alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
}


@end

@implementation TLUpdate$updateContactLocated : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5f83b963;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x35d0d4f0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateContactLocated *object = [[TLUpdate$updateContactLocated alloc] init];
    object.contacts = metaObject->getArray((int32_t)0x48dc7107);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.contacts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x48dc7107, value));
    }
}


@end

@implementation TLUpdate$updateActivation : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6f690963;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1b92ff80;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateActivation *object = [[TLUpdate$updateActivation alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
}


@end

@implementation TLUpdate$updateNewAuthorization : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8f06529a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xedb1c6b6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNewAuthorization *object = [[TLUpdate$updateNewAuthorization alloc] init];
    object.auth_key_id = metaObject->getInt64((int32_t)0x17400465);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.device = metaObject->getString((int32_t)0x8bec2723);
    object.location = metaObject->getString((int32_t)0x504a1f06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.auth_key_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x17400465, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.device;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8bec2723, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.location;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x504a1f06, value));
    }
}


@end

@implementation TLUpdate$updatePhoneCallRequested : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xdad7490e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd2a99b80;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updatePhoneCallRequested *object = [[TLUpdate$updatePhoneCallRequested alloc] init];
    object.phone_call = metaObject->getObject((int32_t)0x77bcd691);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.phone_call;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x77bcd691, value));
    }
}


@end

@implementation TLUpdate$updatePhoneCallConfirmed : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5609ff88;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x65fc818b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updatePhoneCallConfirmed *object = [[TLUpdate$updatePhoneCallConfirmed alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.a_or_b = metaObject->getBytes((int32_t)0xd2c3dff4);
    object.connection = metaObject->getObject((int32_t)0xb5b12f84);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.a_or_b;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2c3dff4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.connection;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb5b12f84, value));
    }
}


@end

@implementation TLUpdate$updatePhoneCallDeclined : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x31ae2cc2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd99045cb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updatePhoneCallDeclined *object = [[TLUpdate$updatePhoneCallDeclined alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

@implementation TLUpdate$updateUserPhoto : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x95313b0c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x88f33ef8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserPhoto *object = [[TLUpdate$updateUserPhoto alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.photo = metaObject->getObject((int32_t)0xe6c52372);
    object.previous = metaObject->getBool((int32_t)0x34505af2);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.previous;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x34505af2, value));
    }
}


@end

@implementation TLUpdate$updateNewEncryptedMessage : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x12bcbd9a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8cfe55d7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNewEncryptedMessage *object = [[TLUpdate$updateNewEncryptedMessage alloc] init];
    object.message = metaObject->getObject((int32_t)0xc43b7853);
    object.qts = metaObject->getInt32((int32_t)0x3c528e55);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.qts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3c528e55, value));
    }
}


@end

@implementation TLUpdate$updateEncryptedChatTyping : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1710f156;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaeaf448f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateEncryptedChatTyping *object = [[TLUpdate$updateEncryptedChatTyping alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7234457c, value));
    }
}


@end

@implementation TLUpdate$updateEncryption : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb4a2e88d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4f822e35;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateEncryption *object = [[TLUpdate$updateEncryption alloc] init];
    object.chat = metaObject->getObject((int32_t)0xa8950b16);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.chat;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa8950b16, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
}


@end

@implementation TLUpdate$updateEncryptedMessagesRead : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x38fe25b7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb8e3d3c4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateEncryptedMessagesRead *object = [[TLUpdate$updateEncryptedMessagesRead alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    object.max_date = metaObject->getInt32((int32_t)0xf4d47b51);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7234457c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf4d47b51, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
}


@end

@implementation TLUpdate$updateChatParticipantDelete : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6e5f8c22;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7fec1b13;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChatParticipantDelete *object = [[TLUpdate$updateChatParticipantDelete alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.version = metaObject->getInt32((int32_t)0x4ea810e9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7234457c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ea810e9, value));
    }
}


@end

@implementation TLUpdate$updateDcOptions : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8e5e9873;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfba8237e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateDcOptions *object = [[TLUpdate$updateDcOptions alloc] init];
    object.dc_options = metaObject->getArray((int32_t)0x25e6c768);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.dc_options;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x25e6c768, value));
    }
}


@end

@implementation TLUpdate$updateUserBlocked : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x80ece81a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7e1f1857;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserBlocked *object = [[TLUpdate$updateUserBlocked alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.blocked = metaObject->getBool((int32_t)0xb651736f);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.blocked;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb651736f, value));
    }
}


@end

@implementation TLUpdate$updateNotifySettings : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbec268ef;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa51d20b5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNotifySettings *object = [[TLUpdate$updateNotifySettings alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.notify_settings = metaObject->getObject((int32_t)0xfa59265);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.notify_settings;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfa59265, value));
    }
}


@end

@implementation TLUpdate$updateUserTyping : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5c486927;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x83cd7672;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserTyping *object = [[TLUpdate$updateUserTyping alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.action = metaObject->getObject((int32_t)0xc2d4a0f7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.action;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc2d4a0f7, value));
    }
}


@end

@implementation TLUpdate$updateChatUserTyping : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9a65ea1f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xecc51515;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChatUserTyping *object = [[TLUpdate$updateChatUserTyping alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.action = metaObject->getObject((int32_t)0xc2d4a0f7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7234457c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.action;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc2d4a0f7, value));
    }
}


@end

@implementation TLUpdate$updateUserName : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa7332b73;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe13ece0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserName *object = [[TLUpdate$updateUserName alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.first_name = metaObject->getString((int32_t)0xa604f05d);
    object.last_name = metaObject->getString((int32_t)0x10662e0e);
    object.username = metaObject->getString((int32_t)0x626830ca);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.first_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa604f05d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.last_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x10662e0e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.username;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x626830ca, value));
    }
}


@end

@implementation TLUpdate$updateServiceNotification : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x382dd3e4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd43b35c5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateServiceNotification *object = [[TLUpdate$updateServiceNotification alloc] init];
    object.type = metaObject->getString((int32_t)0x9211ab0a);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.media = metaObject->getObject((int32_t)0x598de2e7);
    object.popup = metaObject->getBool((int32_t)0xba229289);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.media;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x598de2e7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.popup;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xba229289, value));
    }
}


@end

@implementation TLUpdate$updatePrivacy : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xee3b272a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x80d0afbd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updatePrivacy *object = [[TLUpdate$updatePrivacy alloc] init];
    object.key = metaObject->getObject((int32_t)0x6d6f838d);
    object.rules = metaObject->getArray((int32_t)0x2aa6cca);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.rules;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2aa6cca, value));
    }
}


@end

@implementation TLUpdate$updateUserPhone : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x12b9417b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf4e1bdf6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserPhone *object = [[TLUpdate$updateUserPhone alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.phone = metaObject->getString((int32_t)0x9e6a8d86);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9e6a8d86, value));
    }
}


@end

@implementation TLUpdate$updateNewMessage : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1f2b0afd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1238c8f8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNewMessage *object = [[TLUpdate$updateNewMessage alloc] init];
    object.message = metaObject->getObject((int32_t)0xc43b7853);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
}


@end

@implementation TLUpdate$updateDeleteMessages : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa20db0e5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5e1b624e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateDeleteMessages *object = [[TLUpdate$updateDeleteMessages alloc] init];
    object.messages = metaObject->getArray((int32_t)0x8c97b94f);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
}


@end

@implementation TLUpdate$updateReadHistoryInbox : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9961fd5c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x35d81163;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateReadHistoryInbox *object = [[TLUpdate$updateReadHistoryInbox alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.max_id = metaObject->getInt32((int32_t)0xe2c00ace);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
}


@end

@implementation TLUpdate$updateReadHistoryOutbox : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2f2f21bf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1b325cd6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateReadHistoryOutbox *object = [[TLUpdate$updateReadHistoryOutbox alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.max_id = metaObject->getInt32((int32_t)0xe2c00ace);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
}


@end

@implementation TLUpdate$updateContactLink : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9d2e67c5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x78cd1dc2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateContactLink *object = [[TLUpdate$updateContactLink alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.my_link = metaObject->getObject((int32_t)0xc9f9705a);
    object.foreign_link = metaObject->getObject((int32_t)0x1c49ffaf);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.my_link;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc9f9705a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.foreign_link;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1c49ffaf, value));
    }
}


@end

@implementation TLUpdate$updateReadMessagesContents : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x68c13933;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbff26a94;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateReadMessagesContents *object = [[TLUpdate$updateReadMessagesContents alloc] init];
    object.messages = metaObject->getArray((int32_t)0x8c97b94f);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
}


@end

@implementation TLUpdate$updateChatParticipantAdd : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xea4b0e5c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x73f323cd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChatParticipantAdd *object = [[TLUpdate$updateChatParticipantAdd alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.inviter_id = metaObject->getInt32((int32_t)0x9ddfbd93);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.version = metaObject->getInt32((int32_t)0x4ea810e9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7234457c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.inviter_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ddfbd93, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ea810e9, value));
    }
}


@end

@implementation TLUpdate$updateWebPage : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7f891213;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcb53d8fa;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateWebPage *object = [[TLUpdate$updateWebPage alloc] init];
    object.webpage = metaObject->getObject((int32_t)0x9ae475f8);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.webpage;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ae475f8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
}


@end

@implementation TLUpdate$updateChannelTooLong : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x60946422;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc3d61993;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChannelTooLong *object = [[TLUpdate$updateChannelTooLong alloc] init];
    object.channel_id = metaObject->getInt32((int32_t)0x1cfcdb86);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.channel_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1cfcdb86, value));
    }
}


@end

@implementation TLUpdate$updateChannel : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb6d45656;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc6b3ac6e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChannel *object = [[TLUpdate$updateChannel alloc] init];
    object.channel_id = metaObject->getInt32((int32_t)0x1cfcdb86);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.channel_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1cfcdb86, value));
    }
}


@end

@implementation TLUpdate$updateChannelGroup : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc36c1e3c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x85296c06;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChannelGroup *object = [[TLUpdate$updateChannelGroup alloc] init];
    object.channel_id = metaObject->getInt32((int32_t)0x1cfcdb86);
    object.group = metaObject->getObject((int32_t)0x5a6e0b4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.channel_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1cfcdb86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.group;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a6e0b4, value));
    }
}


@end

@implementation TLUpdate$updateNewChannelMessage : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x62ba04d9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x42a922c5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNewChannelMessage *object = [[TLUpdate$updateNewChannelMessage alloc] init];
    object.message = metaObject->getObject((int32_t)0xc43b7853);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
}


@end

@implementation TLUpdate$updateReadChannelInbox : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4214f37f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc0325936;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateReadChannelInbox *object = [[TLUpdate$updateReadChannelInbox alloc] init];
    object.channel_id = metaObject->getInt32((int32_t)0x1cfcdb86);
    object.max_id = metaObject->getInt32((int32_t)0xe2c00ace);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.channel_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1cfcdb86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
}


@end

@implementation TLUpdate$updateDeleteChannelMessages : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc37521c9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x214271f3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateDeleteChannelMessages *object = [[TLUpdate$updateDeleteChannelMessages alloc] init];
    object.channel_id = metaObject->getInt32((int32_t)0x1cfcdb86);
    object.messages = metaObject->getArray((int32_t)0x8c97b94f);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.channel_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1cfcdb86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
}


@end

@implementation TLUpdate$updateChannelMessageViews : TLUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x98a12b4b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfac722e9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChannelMessageViews *object = [[TLUpdate$updateChannelMessageViews alloc] init];
    object.channel_id = metaObject->getInt32((int32_t)0x1cfcdb86);
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.views = metaObject->getInt32((int32_t)0xe59deddf);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.channel_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1cfcdb86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.views;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe59deddf, value));
    }
}


@end

