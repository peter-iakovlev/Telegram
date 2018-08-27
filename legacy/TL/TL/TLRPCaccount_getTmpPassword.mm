#import "TLRPCaccount_getTmpPassword.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLaccount_TmpPassword.h"

@implementation TLRPCaccount_getTmpPassword


- (Class)responseClass
{
    return [TLaccount_TmpPassword class];
}

- (int)impliedResponseSignature
{
    return (int)0xdb64fd34;
}

- (int)layerVersion
{
    return 64;
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

@implementation TLRPCaccount_getTmpPassword$account_getTmpPassword : TLRPCaccount_getTmpPassword


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x449e0b51;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8b211c75;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_getTmpPassword$account_getTmpPassword *object = [[TLRPCaccount_getTmpPassword$account_getTmpPassword alloc] init];
    object.password = metaObject->getObject((int32_t)0x5aa034f2);
    object.period = metaObject->getInt32((int32_t)0xc19ffb71);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.password;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5aa034f2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.period;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc19ffb71, value));
    }
}


@end

