#import "TLMessageAction.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPhoto.h"

@implementation TLMessageAction


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

@implementation TLMessageAction$messageActionEmpty : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb6aef7b0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x510bb26a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageAction$messageActionEmpty *object = [[TLMessageAction$messageActionEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageAction$messageActionChatCreate : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa6638b9a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6dbcb651;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChatCreate *object = [[TLMessageAction$messageActionChatCreate alloc] init];
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

@implementation TLMessageAction$messageActionChatEditTitle : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb5a1ce5a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb765cec5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChatEditTitle *object = [[TLMessageAction$messageActionChatEditTitle alloc] init];
    object.title = metaObject->getString((int32_t)0xcdebf414);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
}


@end

@implementation TLMessageAction$messageActionChatEditPhoto : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7fcb13a8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x95d33c18;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChatEditPhoto *object = [[TLMessageAction$messageActionChatEditPhoto alloc] init];
    object.photo = metaObject->getObject((int32_t)0xe6c52372);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe6c52372, value));
    }
}


@end

@implementation TLMessageAction$messageActionChatDeletePhoto : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x95e3fbef;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb7e0dd8f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageAction$messageActionChatDeletePhoto *object = [[TLMessageAction$messageActionChatDeletePhoto alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageAction$messageActionChatDeleteUser : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb2ae9b0c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3481dd7e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChatDeleteUser *object = [[TLMessageAction$messageActionChatDeleteUser alloc] init];
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

@implementation TLMessageAction$messageActionSentRequest : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfc479b0f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1faf63c6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionSentRequest *object = [[TLMessageAction$messageActionSentRequest alloc] init];
    object.has_phone = metaObject->getBool((int32_t)0x217cda81);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.has_phone;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x217cda81, value));
    }
}


@end

@implementation TLMessageAction$messageActionAcceptRequest : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7f07d76c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc771c6c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageAction$messageActionAcceptRequest *object = [[TLMessageAction$messageActionAcceptRequest alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageAction$messageActionChatJoinedByLink : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf89cf5e8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x949ac2ac;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChatJoinedByLink *object = [[TLMessageAction$messageActionChatJoinedByLink alloc] init];
    object.inviter_id = metaObject->getInt32((int32_t)0x9ddfbd93);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.inviter_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ddfbd93, value));
    }
}


@end

@implementation TLMessageAction$messageActionChannelCreate : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x95d2ac92;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xde6ac75e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChannelCreate *object = [[TLMessageAction$messageActionChannelCreate alloc] init];
    object.title = metaObject->getString((int32_t)0xcdebf414);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
}


@end

@implementation TLMessageAction$messageActionChannelToggleComments : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf2863903;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x19080453;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChannelToggleComments *object = [[TLMessageAction$messageActionChannelToggleComments alloc] init];
    object.enabled = metaObject->getBool((int32_t)0x335ec0ee);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.enabled;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x335ec0ee, value));
    }
}


@end

@implementation TLMessageAction$messageActionChatMigrateTo : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x51bdb021;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa414884f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChatMigrateTo *object = [[TLMessageAction$messageActionChatMigrateTo alloc] init];
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

@implementation TLMessageAction$messageActionChatDeactivate : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x64ad20a8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5474cbda;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageAction$messageActionChatDeactivate *object = [[TLMessageAction$messageActionChatDeactivate alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageAction$messageActionChatActivate : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x40ad8cb2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7613c945;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageAction$messageActionChatActivate *object = [[TLMessageAction$messageActionChatActivate alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageAction$messageActionChannelMigrateFrom : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb055eaee;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb37541c7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChannelMigrateFrom *object = [[TLMessageAction$messageActionChannelMigrateFrom alloc] init];
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7234457c, value));
    }
}


@end

@implementation TLMessageAction$messageActionChatAddUser : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x488a7337;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf4f77cb2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChatAddUser *object = [[TLMessageAction$messageActionChatAddUser alloc] init];
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

@implementation TLMessageAction$messageActionChatAddUserLegacy : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5e3cfc4b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9bfff3e5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionChatAddUserLegacy *object = [[TLMessageAction$messageActionChatAddUserLegacy alloc] init];
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

@implementation TLMessageAction$messageActionPinMessage : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x94bd38ed;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xce93aa0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageAction$messageActionPinMessage *object = [[TLMessageAction$messageActionPinMessage alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageAction$messageActionHistoryClear : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9fbab604;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8e5afb58;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageAction$messageActionHistoryClear *object = [[TLMessageAction$messageActionHistoryClear alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageAction$messageActionGameScore : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x92a72876;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4e1def96;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionGameScore *object = [[TLMessageAction$messageActionGameScore alloc] init];
    object.game_id = metaObject->getInt64((int32_t)0xdac07ef4);
    object.score = metaObject->getInt32((int32_t)0xe2546678);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.game_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdac07ef4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.score;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2546678, value));
    }
}


@end

@implementation TLMessageAction$messageActionPaymentSent : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x40699cd0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9c224127;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageAction$messageActionPaymentSent *object = [[TLMessageAction$messageActionPaymentSent alloc] init];
    object.currency = metaObject->getString((int32_t)0xd2a84177);
    object.total_amount = metaObject->getInt64((int32_t)0x662699d7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.currency;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2a84177, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.total_amount;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x662699d7, value));
    }
}


@end

@implementation TLMessageAction$messageActionScreenshotTaken : TLMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4792929b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x496da402;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageAction$messageActionScreenshotTaken *object = [[TLMessageAction$messageActionScreenshotTaken alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

