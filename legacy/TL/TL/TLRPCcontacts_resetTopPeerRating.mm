#import "TLRPCcontacts_resetTopPeerRating.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLTopPeerCategory.h"
#import "TLInputPeer.h"

@implementation TLRPCcontacts_resetTopPeerRating


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
    return 52;
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

@implementation TLRPCcontacts_resetTopPeerRating$contacts_resetTopPeerRating : TLRPCcontacts_resetTopPeerRating


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1ae373ac;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb208e389;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCcontacts_resetTopPeerRating$contacts_resetTopPeerRating *object = [[TLRPCcontacts_resetTopPeerRating$contacts_resetTopPeerRating alloc] init];
    object.category = metaObject->getObject((int32_t)0xa9546794);
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.category;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa9546794, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
}


@end

