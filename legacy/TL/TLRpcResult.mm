#import "TLRpcResult.h"

#import "NSInputStream+TL.h"
#import "NSOutputStream+TL.h"

#import "TLMetaClassStore.h"

@implementation TLRpcResult

@synthesize req_msg_id = _req_msg_id;
@synthesize result = _result;

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

@implementation TLRpcResult$rpc_result : TLRpcResult


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf35c6d01;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9265e37f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRpcResult$rpc_result *object = [[TLRpcResult$rpc_result alloc] init];
    object.req_msg_id = metaObject->getInt64(0x96e02a8b);
    object.result = metaObject->getObject(0xf74f3b5e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.req_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x96e02a8b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.result;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xf74f3b5e, value));
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(NSError *__autoreleasing *)error
{
    if (signature != (int32_t)0xf35c6d01)
    {
        if (error)
        {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setValue:[NSString stringWithFormat:@"Invalid signature %.8x (should be 0xf35c6d01)", signature] forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:@"TL" code:-1 userInfo:userInfo];
        }
        
        return nil;
    }
    
    TLRpcResult$rpc_result *result = [[TLRpcResult$rpc_result alloc] init];
    
    result.req_msg_id = [is readInt64];
    TLSerializationContext *innerContext = [environment serializationContextForRpcResult:result.req_msg_id];
    if (innerContext == nil)
    {
        TGLog(@"***** Serialization context for %lld not found, ignoring rpc response", result.req_msg_id);
        
        return result;
    }
    
    int resultSignature = [is readInt32];
    result.result = TLMetaClassStore::constructObject(is, resultSignature, environment, innerContext, error);
    
    if (error != NULL && *error != nil)
    {
        TGLog(@"***** Error parsing response to %lld: %@", result.req_msg_id, *error);
    }
    
    return result;
}

@end

