#import "TLResPQ.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLResPQ


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

@implementation TLResPQ$resPQ : TLResPQ


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5162463;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x486e9ec7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLResPQ$resPQ *object = [[TLResPQ$resPQ alloc] init];
    object.nonce = metaObject->getBytes((int32_t)0x48cbe731);
    object.server_nonce = metaObject->getBytes((int32_t)0xe1dc3f2c);
    object.pq = metaObject->getBytes((int32_t)0x77e01332);
    object.server_public_key_fingerprints = metaObject->getArray((int32_t)0x834b5837);
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.server_nonce;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe1dc3f2c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.pq;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x77e01332, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.server_public_key_fingerprints;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x834b5837, value));
    }
}


@end

