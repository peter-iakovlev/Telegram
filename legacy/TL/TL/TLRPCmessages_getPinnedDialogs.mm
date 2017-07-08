#import "TLRPCmessages_getPinnedDialogs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_PeerDialogs.h"

@implementation TLRPCmessages_getPinnedDialogs


- (Class)responseClass
{
    return [TLmessages_PeerDialogs class];
}

- (int)impliedResponseSignature
{
    return (int)0x3371c354;
}

- (int)layerVersion
{
    return 61;
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

@implementation TLRPCmessages_getPinnedDialogs$messages_getPinnedDialogs : TLRPCmessages_getPinnedDialogs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe254d64e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x32cd5d83;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCmessages_getPinnedDialogs$messages_getPinnedDialogs *object = [[TLRPCmessages_getPinnedDialogs$messages_getPinnedDialogs alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

