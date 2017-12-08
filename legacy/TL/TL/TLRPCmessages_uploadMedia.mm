#import "TLRPCmessages_uploadMedia.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"
#import "TLInputMedia.h"
#import "TLMessageMedia.h"

@implementation TLRPCmessages_uploadMedia


- (Class)responseClass
{
    return [TLMessageMedia class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 73;
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

@implementation TLRPCmessages_uploadMedia$messages_uploadMedia : TLRPCmessages_uploadMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x519bc2b1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5b1f536a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_uploadMedia$messages_uploadMedia *object = [[TLRPCmessages_uploadMedia$messages_uploadMedia alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.media = metaObject->getObject((int32_t)0x598de2e7);
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
        value.nativeObject = self.media;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x598de2e7, value));
    }
}


@end

