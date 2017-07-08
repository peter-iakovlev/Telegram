#import "TLRPCrpc_drop_answer.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLRpcDropAnswer.h"

@implementation TLRPCrpc_drop_answer


- (Class)responseClass
{
    return [TLRpcDropAnswer class];
}

- (int)impliedResponseSignature
{
    return 0;
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

@implementation TLRPCrpc_drop_answer$rpc_drop_answer : TLRPCrpc_drop_answer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x58e4a740;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3d4df5cf;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCrpc_drop_answer$rpc_drop_answer *object = [[TLRPCrpc_drop_answer$rpc_drop_answer alloc] init];
    object.req_msg_id = metaObject->getInt64((int32_t)0x96e02a8b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.req_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x96e02a8b, value));
    }
}


@end

