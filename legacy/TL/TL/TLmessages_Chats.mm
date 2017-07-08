#import "TLmessages_Chats.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_Chats


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

@implementation TLmessages_Chats$messages_chats : TLmessages_Chats


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x64ff9fd5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5ce02966;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_Chats$messages_chats *object = [[TLmessages_Chats$messages_chats alloc] init];
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.chats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4240ad02, value));
    }
}


@end

@implementation TLmessages_Chats$messages_chatsSlice : TLmessages_Chats


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9cd81144;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf5d77925;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_Chats$messages_chatsSlice *object = [[TLmessages_Chats$messages_chatsSlice alloc] init];
    object.count = metaObject->getInt32((int32_t)0x5fa6aa74);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5fa6aa74, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.chats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4240ad02, value));
    }
}


@end

