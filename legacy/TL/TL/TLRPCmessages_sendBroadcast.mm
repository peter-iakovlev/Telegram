#import "TLRPCmessages_sendBroadcast.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputMedia.h"
#import "TLUpdates.h"

@implementation TLRPCmessages_sendBroadcast


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
    return 26;
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

@implementation TLRPCmessages_sendBroadcast$messages_sendBroadcast : TLRPCmessages_sendBroadcast


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbf73f4da;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xafd7bca6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_sendBroadcast$messages_sendBroadcast *object = [[TLRPCmessages_sendBroadcast$messages_sendBroadcast alloc] init];
    object.contacts = metaObject->getArray((int32_t)0x48dc7107);
    object.random_id = metaObject->getArray((int32_t)0xca5a160a);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.media = metaObject->getObject((int32_t)0x598de2e7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.contacts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x48dc7107, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xca5a160a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.media;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x598de2e7, value));
    }
}


@end

