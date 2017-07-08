#import "TLRpcError.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRpcError


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

@implementation TLRpcError$rpc_error : TLRpcError


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2144ca19;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x18d9115d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRpcError$rpc_error *object = [[TLRpcError$rpc_error alloc] init];
    object.error_code = metaObject->getInt32((int32_t)0xd1591cb4);
    object.error_message = metaObject->getString((int32_t)0xabd7b4c9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.error_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd1591cb4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.error_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xabd7b4c9, value));
    }
}


@end

