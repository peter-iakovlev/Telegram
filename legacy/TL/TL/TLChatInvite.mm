#import "TLChatInvite.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChat.h"

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

@implementation TLChatInvite$chatInviteAlready : TLChatInvite


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5a686d7c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1601d4c5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
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

@implementation TLChatInvite$chatInvite : TLChatInvite


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x93e99b60;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7ea3e4d9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLChatInvite$chatInvite *object = [[TLChatInvite$chatInvite alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.title = metaObject->getString((int32_t)0xcdebf414);
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
}


@end

