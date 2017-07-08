#import "TLRPCchannels_editBanned.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"
#import "TLInputUser.h"
#import "TLChannelBannedRights.h"
#import "TLUpdates.h"

@implementation TLRPCchannels_editBanned


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
    return 68;
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

@implementation TLRPCchannels_editBanned$channels_editBanned : TLRPCchannels_editBanned


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbfd915cd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x987e139a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_editBanned$channels_editBanned *object = [[TLRPCchannels_editBanned$channels_editBanned alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.user_id = metaObject->getObject((int32_t)0xafdf4073);
    object.banned_rights = metaObject->getObject((int32_t)0x7ecb6900);
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
        value.nativeObject = self.banned_rights;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7ecb6900, value));
    }
}


@end

