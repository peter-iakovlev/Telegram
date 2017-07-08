#import "TLRPCaccount_setAccountTTL.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLAccountDaysTTL.h"

@implementation TLRPCaccount_setAccountTTL


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
    return 19;
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

@implementation TLRPCaccount_setAccountTTL$account_setAccountTTL : TLRPCaccount_setAccountTTL


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2442485e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc18e8d78;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_setAccountTTL$account_setAccountTTL *object = [[TLRPCaccount_setAccountTTL$account_setAccountTTL alloc] init];
    object.ttl = metaObject->getObject((int32_t)0x6e7be5af);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.ttl;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6e7be5af, value));
    }
}


@end

