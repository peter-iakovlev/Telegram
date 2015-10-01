#import "TLPeerNotifySettings.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPeerNotifySettings


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

@implementation TLPeerNotifySettings$peerNotifySettingsEmpty : TLPeerNotifySettings


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x70a68512;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe73d3124;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPeerNotifySettings$peerNotifySettingsEmpty *object = [[TLPeerNotifySettings$peerNotifySettingsEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPeerNotifySettings$peerNotifySettings : TLPeerNotifySettings


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8d5e11ee;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa5e37dbc;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLPeerNotifySettings$peerNotifySettings *object = [[TLPeerNotifySettings$peerNotifySettings alloc] init];
    object.mute_until = metaObject->getInt32((int32_t)0xb47c7399);
    object.sound = metaObject->getString((int32_t)0x352fa0b9);
    object.show_previews = metaObject->getBool((int32_t)0xccc87c93);
    object.events_mask = metaObject->getInt32((int32_t)0x76f7fd23);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.mute_until;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb47c7399, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.sound;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x352fa0b9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.show_previews;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xccc87c93, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.events_mask;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x76f7fd23, value));
    }
}


@end

