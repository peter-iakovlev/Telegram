#import "TLRPCmessages_readMentions.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"
#import "TLmessages_AffectedHistory.h"

@implementation TLRPCmessages_readMentions


- (Class)responseClass
{
    return [TLmessages_AffectedHistory class];
}

- (int)impliedResponseSignature
{
    return (int)0xb45c69d1;
}

- (int)layerVersion
{
    return 72;
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

@implementation TLRPCmessages_readMentions$messages_readMentions : TLRPCmessages_readMentions


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf0189d3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x28c4e5c7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_readMentions$messages_readMentions *object = [[TLRPCmessages_readMentions$messages_readMentions alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
}


@end

