#import "TLRPCchannels_editAdmin.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"
#import "TLInputUser.h"
#import "TLChannelParticipantRole.h"

@implementation TLRPCchannels_editAdmin


- (Class)responseClass
{
    return [NSNumber class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 38;
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

@implementation TLRPCchannels_editAdmin$channels_editAdmin : TLRPCchannels_editAdmin


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x52b16962;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcdb8de75;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_editAdmin$channels_editAdmin *object = [[TLRPCchannels_editAdmin$channels_editAdmin alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.user_id = metaObject->getObject((int32_t)0xafdf4073);
    object.role = metaObject->getObject((int32_t)0x4040314c);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.role;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4040314c, value));
    }
}


@end

