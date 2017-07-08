#import "TLRPCreq_pq.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLResPQ.h"

@implementation TLRPCreq_pq


- (Class)responseClass
{
    return [TLResPQ class];
}

- (int)impliedResponseSignature
{
    return (int)0x5162463;
}

- (int)layerVersion
{
    return 0;
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

@implementation TLRPCreq_pq$req_pq : TLRPCreq_pq


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x60469778;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdaa01692;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCreq_pq$req_pq *object = [[TLRPCreq_pq$req_pq alloc] init];
    object.nonce = metaObject->getBytes((int32_t)0x48cbe731);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.nonce;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x48cbe731, value));
    }
}


@end

