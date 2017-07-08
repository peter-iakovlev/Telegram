#import "TLRPCmessages_reportEncryptedSpam.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputEncryptedChat.h"

@implementation TLRPCmessages_reportEncryptedSpam


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
    return 62;
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

@implementation TLRPCmessages_reportEncryptedSpam$messages_reportEncryptedSpam : TLRPCmessages_reportEncryptedSpam


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4b0c8c0f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb0de70ca;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_reportEncryptedSpam$messages_reportEncryptedSpam *object = [[TLRPCmessages_reportEncryptedSpam$messages_reportEncryptedSpam alloc] init];
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

