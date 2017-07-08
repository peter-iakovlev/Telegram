#import "TLRPCchannels_toggleInvites.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"
#import "TLUpdates.h"

@implementation TLRPCchannels_toggleInvites


- (Class)responseClass
{
    return [TLUpdates class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 46;
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

@implementation TLRPCchannels_toggleInvites$channels_toggleInvites : TLRPCchannels_toggleInvites


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x49609307;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9d1cc58a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_toggleInvites$channels_toggleInvites *object = [[TLRPCchannels_toggleInvites$channels_toggleInvites alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.enabled = metaObject->getBool((int32_t)0x335ec0ee);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.channel;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe11f3d41, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.enabled;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x335ec0ee, value));
    }
}


@end

