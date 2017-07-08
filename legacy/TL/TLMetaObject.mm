#import "TLMetaObject.h"

TLMetaObject::TLMetaObject(std::shared_ptr<std::vector<TLMetaField> > fields_, std::shared_ptr<std::unordered_map<int32_t, int> > fieldNameToIndex_, std::shared_ptr<std::vector<TLConstructedValue> > values_)
{
    fields = fields_;
    fieldNameToIndex = fieldNameToIndex_;
    values = values_;
}

TLMetaObject::TLMetaObject(const TLMetaObject &other)
{
    fields = other.fields;
    fieldNameToIndex = other.fieldNameToIndex;
    values = other.values;
}

TLMetaObject & TLMetaObject::operator= (const TLMetaObject &other)
{
    if (this != &other)
    {
        fields = other.fields;
        fieldNameToIndex = other.fieldNameToIndex;
        values = other.values;
    }
    return *this;
}

TLMetaObject::~TLMetaObject()
{
}

int32_t TLMetaObject::getInt32(int32_t name)
{
    std::unordered_map<int32_t, int>::iterator it = fieldNameToIndex->find(name);
    if (it == fieldNameToIndex->end())
        return 0;
    
    switch (values->at((size_t)it->second).type)
    {
        case TLConstructedValueTypePrimitiveInt32:
            return values->at((size_t)it->second).primitive.int32Value;
        case TLConstructedValueTypePrimitiveInt64:
            return (int32_t)(values->at((size_t)it->second).primitive.int64Value);
        case TLConstructedValueTypePrimitiveDouble:
            return (int32_t)values->at((size_t)it->second).primitive.doubleValue;
        case TLConstructedValueTypePrimitiveBool:
            return values->at((size_t)it->second).primitive.boolValue ? 1 : 0;
        default:
            break;
    }
    
    return 0;
}

int64_t TLMetaObject::getInt64(int32_t name)
{
    std::unordered_map<int32_t, int>::iterator it = fieldNameToIndex->find(name);
    if (it == fieldNameToIndex->end())
        return 0;
    
    switch (values->at((size_t)it->second).type)
    {
        case TLConstructedValueTypePrimitiveInt32:
            return (int64_t)values->at((size_t)it->second).primitive.int32Value;
        case TLConstructedValueTypePrimitiveInt64:
            return (values->at((size_t)it->second).primitive.int64Value);
        case TLConstructedValueTypePrimitiveDouble:
            return (int64_t)values->at((size_t)it->second).primitive.doubleValue;
        case TLConstructedValueTypePrimitiveBool:
            return values->at((size_t)it->second).primitive.boolValue ? 1 : 0;
        default:
            break;
    }
    
    return 0;
}

double TLMetaObject::getDouble(int32_t name)
{
    std::unordered_map<int32_t, int>::iterator it = fieldNameToIndex->find(name);
    if (it == fieldNameToIndex->end())
        return 0.0;
    
    switch (values->at((size_t)it->second).type)
    {
        case TLConstructedValueTypePrimitiveInt32:
            return (double)values->at((size_t)it->second).primitive.int32Value;
        case TLConstructedValueTypePrimitiveInt64:
            return (double)(values->at((size_t)it->second).primitive.int64Value);
        case TLConstructedValueTypePrimitiveDouble:
            return values->at((size_t)it->second).primitive.doubleValue;
        case TLConstructedValueTypePrimitiveBool:
            return values->at((size_t)it->second).primitive.boolValue ? 1 : 0;
        default:
            break;
    }
    
    return 0.0;
}

bool TLMetaObject::getBool(int32_t name)
{
    std::unordered_map<int32_t, int>::iterator it = fieldNameToIndex->find(name);
    if (it == fieldNameToIndex->end())
        return false;
    
    switch (values->at((size_t)it->second).type)
    {
        case TLConstructedValueTypePrimitiveInt32:
            return values->at((size_t)it->second).primitive.int32Value != 0;
        case TLConstructedValueTypePrimitiveInt64:
            return values->at((size_t)it->second).primitive.int64Value != 0;
        case TLConstructedValueTypePrimitiveDouble:
            return values->at((size_t)it->second).primitive.doubleValue != 0.0;
        case TLConstructedValueTypePrimitiveBool:
            return values->at((size_t)it->second).primitive.boolValue;
        default:
            break;
    }
    
    return false;
}

NSData *TLMetaObject::getBytes(int32_t name)
{
    static Class class_NSData = [NSData class];
    
    std::unordered_map<int32_t, int>::iterator it = fieldNameToIndex->find(name);
    if (it == fieldNameToIndex->end())
        return nil;
    
    switch (values->at((size_t)it->second).type)
    {
        case TLConstructedValueTypeBytes:
        {
            id object = values->at((size_t)it->second).nativeObject;
            if (object != nil && ![object isKindOfClass:class_NSData])
            {
                TGLog(@"***** Failed to extract bytes from %@", object);
                return nil;
            }
            return object;
        }
        default:
            break;
    }
    
    return nil;
}

NSString *TLMetaObject::getString(int32_t name)
{
    static Class class_NSString = [NSString class];
    
    std::unordered_map<int32_t, int>::iterator it = fieldNameToIndex->find(name);
    if (it == fieldNameToIndex->end())
        return nil;
    
    switch (values->at((size_t)it->second).type)
    {
        case TLConstructedValueTypeString:
        {
            id object = values->at((size_t)it->second).nativeObject;
            if (object != nil && ![object isKindOfClass:class_NSString])
            {
                TGLog(@"***** Failed to extract string from %@", object);
                return nil;
            }
            return object;
        }
        default:
            break;
    }
    
    return nil;
}

NSArray *TLMetaObject::getArray(int32_t name)
{
    static Class class_NSArray = [NSArray class];
    
    std::unordered_map<int32_t, int>::iterator it = fieldNameToIndex->find(name);
    if (it == fieldNameToIndex->end())
        return nil;
    
    switch (values->at((size_t)it->second).type)
    {
        case TLConstructedValueTypeVector:
        {
            id object = values->at((size_t)it->second).nativeObject;
            if (object != nil && ![object isKindOfClass:class_NSArray])
            {
                TGLog(@"***** Failed to extract array from %@", object);
                return nil;
            }
            return object;
        }
        default:
            break;
    }
    
    return nil;
}

id TLMetaObject::getObject(int32_t name)
{
    std::unordered_map<int32_t, int>::iterator it = fieldNameToIndex->find(name);
    if (it == fieldNameToIndex->end())
        return nil;
    
    switch (values->at((size_t)it->second).type)
    {
        case TLConstructedValueTypeObject:
        case TLConstructedValueTypeVector:
        case TLConstructedValueTypeString:
        case TLConstructedValueTypeBytes:
        {
            id object = values->at((size_t)it->second).nativeObject;
            return object;
        }
        case TLConstructedValueTypePrimitiveInt32:
        {
            return [NSNumber numberWithInt:values->at((size_t)it->second).primitive.int32Value];
        }
        case TLConstructedValueTypePrimitiveInt64:
        {
            return [NSNumber numberWithLongLong:values->at((size_t)it->second).primitive.int64Value];
        }
        case TLConstructedValueTypePrimitiveDouble:
        {
            return [NSNumber numberWithDouble:values->at((size_t)it->second).primitive.doubleValue];
        }
        case TLConstructedValueTypePrimitiveBool:
        {
            return [NSNumber numberWithBool:values->at((size_t)it->second).primitive.boolValue];
        }
        default:
            break;
    }
    
    return nil;
}
