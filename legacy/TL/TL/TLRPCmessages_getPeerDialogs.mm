#import "TLRPCmessages_getPeerDialogs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_PeerDialogs.h"

@implementation TLRPCmessages_getPeerDialogs


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
    return 52;
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

@implementation TLRPCmessages_getPeerDialogs$messages_getPeerDialogs : TLRPCmessages_getPeerDialogs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2d9776b9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5b786ef7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getPeerDialogs$messages_getPeerDialogs *object = [[TLRPCmessages_getPeerDialogs$messages_getPeerDialogs alloc] init];
    object.peers = metaObject->getArray((int32_t)0x7cd8de36);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.peers;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7cd8de36, value));
    }
}


@end

