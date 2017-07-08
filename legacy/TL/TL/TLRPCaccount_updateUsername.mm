#import "TLRPCaccount_updateUsername.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUser.h"

@implementation TLRPCaccount_updateUsername


- (Class)responseClass
{
    return [TLUser class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 18;
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

@implementation TLRPCaccount_updateUsername$account_updateUsername : TLRPCaccount_updateUsername


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3e0bdd7c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2dc6b67;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_updateUsername$account_updateUsername *object = [[TLRPCaccount_updateUsername$account_updateUsername alloc] init];
    object.username = metaObject->getString((int32_t)0x626830ca);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.username;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x626830ca, value));
    }
}


@end

