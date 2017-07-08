#import "TLRPCcontacts_acceptRequest.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"
#import "TLcontacts_Link.h"

@implementation TLRPCcontacts_acceptRequest


- (Class)responseClass
{
    return [TLcontacts_Link class];
}

- (int)impliedResponseSignature
{
    return (int)0x3ace484c;
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

@implementation TLRPCcontacts_acceptRequest$contacts_acceptRequest : TLRPCcontacts_acceptRequest


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x946c1f91;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xeb927049;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCcontacts_acceptRequest$contacts_acceptRequest *object = [[TLRPCcontacts_acceptRequest$contacts_acceptRequest alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

