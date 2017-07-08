/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef __Telegraph__TLMetaClassStore__
#define __Telegraph__TLMetaClassStore__

#include <Foundation/Foundation.h>

#include "TLMetaType.h"
#include "TLConstructedValue.h"
#include "TLMetaConstructor.h"
#include "TLMetaObject.h"
#import "TLObject.h"

#import "TL/TLMetaScheme.h"

#include <unordered_map>

#define TL_INT32_CONSTRUCTOR ((int32_t)0xA8509BDA)
#define TL_INT64_CONSTRUCTOR ((int32_t)0x22076CBA)
#define TL_INT128_CONSTRUCTOR ((int32_t)0x4BB5362B)
#define TL_INT256_CONSTRUCTOR ((int32_t)0x0929C32F)
#define TL_DOUBLE_CONSTRUCTOR ((int32_t)0x2210C154)
#define TL_STRING_CONSTRUCTOR ((int32_t)0xB5286E24)
#define TL_BYTES_CONSTRUCTOR ((int32_t)0xEBEFB69E)
#define TL_BOOL_TRUE_CONSTRUCTOR ((int32_t)0x997275B5)
#define TL_BOOL_FALSE_CONSTRUCTOR ((int32_t)0xBC799737)
#define TL_NULL_CONSTRUCTOR ((int32_t)0x56730BCC)
#define TL_UNIVERSAL_VECTOR_CONSTRUCTOR ((int32_t)0x1cb5c415)

#define TG_USE_UNIVERSAL_VECTOR true

class TLMetaClassStore
{
private:
    static std::unordered_map<int32_t, std::shared_ptr<TLMetaConstructor> > constructorsBySignature;
    static std::unordered_map<int32_t, std::shared_ptr<TLMetaConstructor> > constructorsByName;
    static std::unordered_map<int32_t, std::shared_ptr<TLMetaType> > typesByName;
    static std::unordered_map<int32_t, TLMetaTypeArgument> vectorElementTypesByConstructor;
    
    static std::unordered_map<int32_t, id<TLObject> > objectClassesByConstructorNames;
    static std::unordered_map<int32_t, id<TLVector> > vectorClassesBySignature;
    
    static std::unordered_map<int32_t, id<TLObject> > manualObjectParsers;
    static std::unordered_map<int32_t, id<TLObject> > manualObjectSerializers;
    
public:
    static void registerObjectClass(id<TLObject> objectClass);
    static void registerVectorClass(id<TLVector> vectorClass);
    static id<TLObject> getObjectClass(int32_t name);
    
    static void clearScheme();
    static void mergeScheme(TLScheme *scheme);
    
    static inline std::shared_ptr<TLMetaConstructor> getConstructorBySignature(int32_t signature)
    {
        std::unordered_map<int32_t, std::shared_ptr<TLMetaConstructor> >::iterator it = constructorsBySignature.find(signature);
        return it != constructorsBySignature.end() ? it->second : std::shared_ptr<TLMetaConstructor>();
    }
    
    static inline std::shared_ptr<TLMetaConstructor> getConstructorByName(int32_t name)
    {
        std::unordered_map<int32_t, std::shared_ptr<TLMetaConstructor> >::iterator it = constructorsByName.find(name);
        return it != constructorsByName.end() ? it->second : std::shared_ptr<TLMetaConstructor>();
    }
    
    static id constructObject(NSInputStream *is, int32_t signature, id<TLSerializationEnvironment> environment, TLSerializationContext *context, __autoreleasing NSError **error);
    static void serializeObject(NSOutputStream *os, id<TLObject> object, bool boxed);
    
    static TLConstructedValue constructValue(NSInputStream *is, int32_t signature, id<TLSerializationEnvironment> environment, TLSerializationContext *context, __autoreleasing NSError **error);
};

#endif
