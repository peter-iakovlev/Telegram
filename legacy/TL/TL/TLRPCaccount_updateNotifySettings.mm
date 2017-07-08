#import "TLRPCaccount_updateNotifySettings.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputNotifyPeer.h"
#import "TLInputPeerNotifySettings.h"

@implementation TLRPCaccount_updateNotifySettings


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
    return 8;
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

@implementation TLRPCaccount_updateNotifySettings$account_updateNotifySettings : TLRPCaccount_updateNotifySettings


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x84be5b93;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1aafa7e1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_updateNotifySettings$account_updateNotifySettings *object = [[TLRPCaccount_updateNotifySettings$account_updateNotifySettings alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.settings = metaObject->getObject((int32_t)0xb494353e);
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
        value.nativeObject = self.settings;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb494353e, value));
    }
}


@end

