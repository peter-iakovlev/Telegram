#import "TLRPCmessages_setTyping.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"
#import "TLSendMessageAction.h"

@implementation TLRPCmessages_setTyping


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
    return 17;
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

@implementation TLRPCmessages_setTyping$messages_setTyping : TLRPCmessages_setTyping


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa3825e50;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6a09a1dd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_setTyping$messages_setTyping *object = [[TLRPCmessages_setTyping$messages_setTyping alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.action = metaObject->getObject((int32_t)0xc2d4a0f7);
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.action;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc2d4a0f7, value));
    }
}


@end

