#import "TLChannelParticipantRole.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLChannelParticipantRole


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

@implementation TLChannelParticipantRole$channelRoleEmpty : TLChannelParticipantRole


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb285a0c6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf9b1f5c1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelParticipantRole$channelRoleEmpty *object = [[TLChannelParticipantRole$channelRoleEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChannelParticipantRole$channelRoleModerator : TLChannelParticipantRole


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9618d975;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc5ea95f2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelParticipantRole$channelRoleModerator *object = [[TLChannelParticipantRole$channelRoleModerator alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChannelParticipantRole$channelRoleEditor : TLChannelParticipantRole


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x820bfe8c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7b5178e0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelParticipantRole$channelRoleEditor *object = [[TLChannelParticipantRole$channelRoleEditor alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

