/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef Telegraph_TLConstructedValue_h
#define Telegraph_TLConstructedValue_h

#include <Foundation/Foundation.h>

#include <memory>

class TLMetaObject;

typedef enum {
    TLConstructedValueTypeEmpty = -1,
    TLConstructedValueTypeObject = 0,
    TLConstructedValueTypePrimitiveInt32 = 1,
    TLConstructedValueTypePrimitiveInt64 = 2,
    TLConstructedValueTypePrimitiveDouble = 3,
    TLConstructedValueTypePrimitiveBool = 4,
    TLConstructedValueTypeString = 5,
    TLConstructedValueTypeBytes = 6,
    TLConstructedValueTypeVector = 7
} TLConstructedValueType;

class TLConstructedValue
{
public:
    TLConstructedValueType type;
    
    union {
        int32_t int32Value;
        int64_t int64Value;
        double doubleValue;
        bool boolValue;
    } primitive;
    
    id nativeObject;
    
public:
    TLConstructedValue() :
        type(TLConstructedValueTypeEmpty), nativeObject(nil)
    {
    }
    
    TLConstructedValue(const TLConstructedValue &other)
    {
        type = other.type;
        primitive = other.primitive;
        nativeObject = other.nativeObject;
    }
    
    ~TLConstructedValue()
    {
        nativeObject = nil;
    }
    
    const TLConstructedValue & operator=(TLConstructedValue & other)
    {
        if (&other != this)
        {
            type = other.type;
            primitive = other.primitive;
            nativeObject = other.nativeObject;
        }
        
        return *this;
    }
};

#endif
