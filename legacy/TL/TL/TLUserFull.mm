#import "TLUserFull.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUser.h"
#import "TLcontacts_Link.h"
#import "TLPhoto.h"
#import "TLPeerNotifySettings.h"
#import "TLBotInfo.h"

@implementation TLUserFull


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

@implementation TLUserFull$userFull : TLUserFull


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5a89ac5b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6d7a1c3a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUserFull$userFull *object = [[TLUserFull$userFull alloc] init];
    object.user = metaObject->getObject((int32_t)0x2275eda7);
    object.link = metaObject->getObject((int32_t)0xc58224f9);
    object.profile_photo = metaObject->getObject((int32_t)0xbc78165);
    object.notify_settings = metaObject->getObject((int32_t)0xfa59265);
    object.blocked = metaObject->getBool((int32_t)0xb651736f);
    object.bot_info = metaObject->getObject((int32_t)0x69c36beb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2275eda7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.link;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc58224f9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.profile_photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbc78165, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.notify_settings;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfa59265, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.blocked;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb651736f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.bot_info;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x69c36beb, value));
    }
}


@end

