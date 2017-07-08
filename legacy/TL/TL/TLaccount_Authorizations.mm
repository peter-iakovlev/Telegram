#import "TLaccount_Authorizations.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLaccount_Authorizations


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

@implementation TLaccount_Authorizations$account_authorizations : TLaccount_Authorizations


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1250abde;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5c49a405;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_Authorizations$account_authorizations *object = [[TLaccount_Authorizations$account_authorizations alloc] init];
    object.authorizations = metaObject->getArray((int32_t)0x789949f8);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.authorizations;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x789949f8, value));
    }
}


@end

