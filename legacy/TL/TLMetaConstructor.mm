#include "TLMetaConstructor.h"

#import "NSInputStream+TL.h"
#import "NSOutputStream+TL.h"

#include "TLMetaClassStore.h"

#import "TLObject.h"

TLMetaConstructor::TLMetaConstructor(int32_t name_, int32_t signature_, std::shared_ptr<std::vector<TLMetaField> > fields_, std::shared_ptr<TLMetaType> resultType_) :
    name(name_), signature(signature_), fields(fields_), resultType(resultType_)
{
    fieldNameToIndex = std::shared_ptr<std::unordered_map<int32_t, int> >(new std::unordered_map<int32_t, int>());
    
    std::vector<TLMetaField>::iterator fieldsEnd = fields->end();
    int index = -1;
    for (std::vector<TLMetaField>::iterator it = fields->begin(); it != fieldsEnd; it++)
    {
        index++;
        fieldNameToIndex->insert(std::pair<int32_t, int>(it->name, index));
    }
}

TLMetaConstructor::~TLMetaConstructor()
{
}

TLConstructedValue TLMetaConstructor::construct(NSInputStream *is, id<TLSerializationEnvironment> environment, __unused TLSerializationContext *context, __autoreleasing NSError **error)
{
    std::shared_ptr<std::vector<TLConstructedValue> > values(new std::vector<TLConstructedValue>());
    
    std::vector<TLMetaField>::iterator fieldsEnd = fields->end();
    for (std::vector<TLMetaField>::iterator it = fields->begin(); it != fieldsEnd; it++)
    {
        int32_t signature = 0;
        if (it->type.boxed)
            signature = [is readInt32];
        else
            signature = it->type.unboxedConstructorSignature;
        
        if (signature == TL_UNIVERSAL_VECTOR_CONSTRUCTOR && it->type.unboxedConstructorSignature != 0)
            signature = it->type.unboxedConstructorSignature;
        
        TLConstructedValue value = TLMetaClassStore::constructValue(is, signature, environment, nil, error);
        if (error != nil && *error != nil)
            return TLConstructedValue();
        
        values->push_back(value);
    }
    
    id<TLObject> objectClass = TLMetaClassStore::getObjectClass(name);
    if (objectClass == nil)
    {
        if (error != NULL)
        {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setValue:[NSString stringWithFormat:@"Object with name %.8x not found", name] forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:@"TL" code:-1 userInfo:userInfo];
        }
        return TLConstructedValue();
    }
    
    TLConstructedValue result;
    result.type = TLConstructedValueTypeObject;
    std::shared_ptr<TLMetaObject> metaObject(new TLMetaObject(fields, fieldNameToIndex, values));
    result.nativeObject = [objectClass TLbuildFromMetaObject:metaObject];
    
    return result;
}

static void writeValueWithType(NSOutputStream *os, TLConstructedValue const &value, TLMetaTypeArgument const &type)
{   
    switch (value.type)
    {
        case TLConstructedValueTypeEmpty:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    if (type.boxed)
                        [os writeInt32:TL_NULL_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_STRING_CONSTRUCTOR];
                    [os writeString:nil];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:0.0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.unboxedConstructorSignature != 0)
                    {
                        if (type.boxed)
                        {
#if TG_USE_UNIVERSAL_VECTOR
                            [os writeInt32:TL_UNIVERSAL_VECTOR_CONSTRUCTOR];
#else
                            [os writeInt32:type.unboxedConstructorSignature];
#endif
                        }
                        [os writeInt32:0];
                    }
                    else
                    {
                        TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        if (type.boxed)
                            [os writeInt32:TL_NULL_CONSTRUCTOR];
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 2");
                    break;
                }
            }
            break;
        }
        case TLConstructedValueTypeObject:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    TLMetaClassStore::serializeObject(os, value.nativeObject, type.boxed);
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_STRING_CONSTRUCTOR];
                    [os writeString:nil];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:0.0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.unboxedConstructorSignature != 0)
                    {
                        if (type.boxed)
                            [os writeInt32:type.unboxedConstructorSignature];
                        [os writeInt32:0];
                    }
                    else
                    {
                        TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        if (type.boxed)
                            [os writeInt32:TL_NULL_CONSTRUCTOR];
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 3");
                    break;
                }
            }
            break;
        }
        case TLConstructedValueTypePrimitiveInt32:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    if (type.boxed)
                        [os writeInt32:TL_NULL_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:value.primitive.int32Value];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:(int64_t)value.primitive.int32Value];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_STRING_CONSTRUCTOR];
                    [os writeString:nil];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:(double)value.primitive.int32Value];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:value.primitive.int32Value != 0 ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.unboxedConstructorSignature != 0)
                    {
                        if (type.boxed)
                        {
#if TG_USE_UNIVERSAL_VECTOR
                            [os writeInt32:TL_UNIVERSAL_VECTOR_CONSTRUCTOR];
#else
                            [os writeInt32:type.unboxedConstructorSignature];
#endif
                        }
                        [os writeInt32:0];
                    }
                    else
                    {
                        TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        if (type.boxed)
                            [os writeInt32:TL_NULL_CONSTRUCTOR];
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 4");
                    break;
                }
            }
            break;
        }
        case TLConstructedValueTypePrimitiveInt64:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    if (type.boxed)
                        [os writeInt32:TL_NULL_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:(int32_t)value.primitive.int64Value];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:value.primitive.int64Value];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_STRING_CONSTRUCTOR];
                    [os writeString:nil];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:(double)value.primitive.int64Value];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:value.primitive.int64Value != 0 ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.unboxedConstructorSignature != 0)
                    {
                        if (type.boxed)
                        {
#if TG_USE_UNIVERSAL_VECTOR
                            [os writeInt32:TL_UNIVERSAL_VECTOR_CONSTRUCTOR];
#else
                            [os writeInt32:type.unboxedConstructorSignature];
#endif
                        }
                        [os writeInt32:0];
                    }
                    else
                    {
                        TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        if (type.boxed)
                            [os writeInt32:TL_NULL_CONSTRUCTOR];
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 5");
                    break;
                }
            }
            break;
        }
        case TLConstructedValueTypePrimitiveDouble:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    if (type.boxed)
                        [os writeInt32:TL_NULL_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:(int32_t)value.primitive.doubleValue];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:(int64_t)value.primitive.doubleValue];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_STRING_CONSTRUCTOR];
                    [os writeString:nil];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:value.primitive.doubleValue];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:value.primitive.doubleValue != 0.0 ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.unboxedConstructorSignature != 0)
                    {
                        if (type.boxed)
                        {
#if TG_USE_UNIVERSAL_VECTOR
                            [os writeInt32:TL_UNIVERSAL_VECTOR_CONSTRUCTOR];
#else
                            [os writeInt32:type.unboxedConstructorSignature];
#endif
                        }
                        [os writeInt32:0];
                    }
                    else
                    {
                        TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        if (type.boxed)
                            [os writeInt32:TL_NULL_CONSTRUCTOR];
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 6");
                    break;
                }
            }
            break;
        }
        case TLConstructedValueTypePrimitiveBool:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    if (type.boxed)
                        [os writeInt32:TL_NULL_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:(int32_t)(value.primitive.boolValue ? 1 : 0)];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:(int64_t)(value.primitive.boolValue ? 1 : 0)];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_STRING_CONSTRUCTOR];
                    [os writeString:nil];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:(value.primitive.boolValue ? 1 : 0)];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:value.primitive.boolValue ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.unboxedConstructorSignature != 0)
                    {
                        if (type.boxed)
                        {
#if TG_USE_UNIVERSAL_VECTOR
                            [os writeInt32:TL_UNIVERSAL_VECTOR_CONSTRUCTOR];
#else
                            [os writeInt32:type.unboxedConstructorSignature];
#endif
                        }
                        [os writeInt32:0];
                    }
                    else
                    {
                        TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        if (type.boxed)
                            [os writeInt32:TL_NULL_CONSTRUCTOR];
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 6");
                    break;
                }
            }
            break;
        }
        case TLConstructedValueTypeString:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    if (type.boxed)
                        [os writeInt32:TL_NULL_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_STRING_CONSTRUCTOR];
                    NSString *string = value.nativeObject;
                    [os writeString:string];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBytes:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BYTES_CONSTRUCTOR];
                    NSString *string = value.nativeObject;
                    [os writeBytes:[string dataUsingEncoding:NSUTF8StringEncoding]];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:0.0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.unboxedConstructorSignature != 0)
                    {
                        if (type.boxed)
                        {
#if TG_USE_UNIVERSAL_VECTOR
                            [os writeInt32:TL_UNIVERSAL_VECTOR_CONSTRUCTOR];
#else
                            [os writeInt32:type.unboxedConstructorSignature];
#endif
                        }
                        [os writeInt32:0];
                    }
                    else
                    {
                        TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        if (type.boxed)
                            [os writeInt32:TL_NULL_CONSTRUCTOR];
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 6");
                    break;
                }
            }
            break;
        }
        case TLConstructedValueTypeBytes:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    if (type.boxed)
                        [os writeInt32:TL_NULL_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    NSData *data = value.nativeObject;
                    if (data.length == 16)
                    {
                        [os writeData:data];
                    }
                    else
                    {
                        [os writeInt64:0];
                        [os writeInt64:0];
                    }
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    NSData *data = value.nativeObject;
                    if (data.length == 32)
                    {
                        [os writeData:data];
                    }
                    else
                    {
                        [os writeInt64:0];
                        [os writeInt64:0];
                        [os writeInt64:0];
                        [os writeInt64:0];
                    }
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_STRING_CONSTRUCTOR];
                    NSData *data = value.nativeObject;
                    [os writeBytes:data];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBytes:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BYTES_CONSTRUCTOR];
                    NSData *data = value.nativeObject;
                    [os writeBytes:data];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:0.0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.unboxedConstructorSignature != 0)
                    {
                        if (type.boxed)
                        {
#if TG_USE_UNIVERSAL_VECTOR
                            [os writeInt32:TL_UNIVERSAL_VECTOR_CONSTRUCTOR];
#else
                            [os writeInt32:type.unboxedConstructorSignature];
#endif
                        }
                        [os writeInt32:0];
                    }
                    else
                    {
                        TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        if (type.boxed)
                            [os writeInt32:TL_NULL_CONSTRUCTOR];
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 6");
                    break;
                }
            }
            break;
        }
        case TLConstructedValueTypeVector:
        {
            switch (type.type->getCategory())
            {
                case TLMetaTypeCategoryObject:
                {
                    if (type.boxed)
                        [os writeInt32:TL_NULL_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt32:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT32_CONSTRUCTOR];
                    [os writeInt32:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt64:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT64_CONSTRUCTOR];
                    [os writeInt64:0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt128:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT128_CONSTRUCTOR];
                    NSData *data = value.nativeObject;
                    if (data.length == 16)
                    {
                        [os writeData:data];
                    }
                    else
                    {
                        [os writeInt64:0];
                        [os writeInt64:0];
                    }
                    break;
                }
                case TLMetaTypeCategoryBuiltinInt256:
                {
                    if (type.boxed)
                        [os writeInt32:TL_INT256_CONSTRUCTOR];
                    NSData *data = value.nativeObject;
                    if (data.length == 32)
                    {
                        [os writeData:data];
                    }
                    else
                    {
                        [os writeInt64:0];
                        [os writeInt64:0];
                        [os writeInt64:0];
                        [os writeInt64:0];
                    }
                    break;
                }
                case TLMetaTypeCategoryBuiltinBytes:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BYTES_CONSTRUCTOR];
                    NSData *data = value.nativeObject;
                    [os writeBytes:data];
                    break;
                }
                case TLMetaTypeCategoryBuiltinString:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BYTES_CONSTRUCTOR];
                    NSString *string = value.nativeObject;
                    [os writeString:string];
                    break;
                }
                case TLMetaTypeCategoryBuiltinDouble:
                {
                    if (type.boxed)
                        [os writeInt32:TL_DOUBLE_CONSTRUCTOR];
                    [os writeDouble:0.0];
                    break;
                }
                case TLMetaTypeCategoryBuiltinBool:
                {
                    if (type.boxed)
                        [os writeInt32:TL_BOOL_FALSE_CONSTRUCTOR];
                    break;
                }
                case TLMetaTypeCategoryBuiltinVector:
                {
                    if (type.boxed)
                    {
                        if (type.unboxedConstructorSignature != 0)
                        {
#if TG_USE_UNIVERSAL_VECTOR
                            [os writeInt32:TL_UNIVERSAL_VECTOR_CONSTRUCTOR];
#else
                            [os writeInt32:type.unboxedConstructorSignature];
#endif
                        }
                        else
                        {
                            TGLog(@"***** Unboxed constructor for 0x%.8x not found", type.type->getName());
                        }
                    }

                    NSArray *array = value.nativeObject;
                    [os writeInt32:(int32_t)array.count];
                    TLMetaTypeArgument const &typeArgument = type.type->getArguments()[0];
                    
                    const int convertInt32 = 1;
                    const int convertInt64 = 2;
                    const int convertString = 3;
                    
                    int conversionType = 0;
                    switch (typeArgument.type->getCategory())
                    {
                        case TLMetaTypeCategoryBuiltinInt32:
                            conversionType = convertInt32;
                            break;
                        case TLMetaTypeCategoryBuiltinInt64:
                            conversionType = convertInt64;
                            break;
                        case TLMetaTypeCategoryObject:
                            conversionType = 0;
                            break;
                        case TLMetaTypeCategoryBuiltinString:
                            conversionType = 3;
                            break;
                        default:
                            TGLog(@"***** Vector element conversion is not implemented");
                            break;
                    }
                    
                    for (id item in array)
                    {   
                        TLConstructedValue itemValue;
                        switch (conversionType)
                        {
                            case convertInt32:
                            {
                                itemValue.type = TLConstructedValueTypePrimitiveInt32;
                                itemValue.primitive.int32Value = [item intValue];
                                break;
                            }
                            case convertInt64:
                            {
                                itemValue.type = TLConstructedValueTypePrimitiveInt64;
                                itemValue.primitive.int64Value = [item longLongValue];
                                break;
                            }
                            case convertString:
                            {
                                itemValue.type = TLConstructedValueTypeString;
                                itemValue.nativeObject = item;
                                break;
                            }
                            default:
                            {
                                itemValue.type = TLConstructedValueTypeObject;
                                itemValue.nativeObject = item;
                            }
                        }
                    
                        writeValueWithType(os, itemValue, typeArgument);
                    }
                    break;
                }
                default:
                {
                    TGLog(@"***** This should never happen 6");
                    break;
                }
            }
            break;
        }
        default:
            TGLog(@"***** This should never happen 1");
    }
}

void TLMetaConstructor::serialize(NSOutputStream *os, id object_)
{
    id<TLObject> object = (id<TLObject>)object_;
    
    std::map<int32_t, TLConstructedValue> fieldValues;
    [object TLfillFieldsWithValues:&fieldValues];
    
    std::vector<TLMetaField>::iterator fieldsEnd = fields->end();
    for (std::vector<TLMetaField>::iterator it = fields->begin(); it != fieldsEnd; it++)
    {   
        std::map<int32_t, TLConstructedValue>::iterator fieldIt = fieldValues.find(it->name);
        if (fieldIt == fieldValues.end())
        {
            [object TLconstructorSignature];
            TGLog(@"***** Field %.8x not found, writing empty value instead", it->name);
            writeValueWithType(os, TLConstructedValue(), it->type);
        }
        else
        {
            writeValueWithType(os, fieldIt->second, it->type);
        }
    }
}
