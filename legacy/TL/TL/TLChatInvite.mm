#import "TLChatInvite.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChat.h"
#import "TLChatPhoto.h"

@implementation TLChatInvite


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

@implementation TLChatInvite$chatInviteAlready : TLChatInvite


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5a686d7c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1601d4c5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChatInvite$chatInviteAlready *object = [[TLChatInvite$chatInviteAlready alloc] init];
    object.chat = metaObject->getObject((int32_t)0xa8950b16);
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
}


@end

@implementation TLChatInvite$chatInviteMeta : TLChatInvite


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7b4b5b37;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9906c635;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChatInvite$chatInviteMeta *object = [[TLChatInvite$chatInviteMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.photo = metaObject->getObject((int32_t)0xe6c52372);
    object.participants_count = metaObject->getInt32((int32_t)0xeb6aa445);
    object.participants = metaObject->getArray((int32_t)0xe0e25c28);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.participants_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeb6aa445, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.participants;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe0e25c28, value));
    }
}


@end

