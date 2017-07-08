/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef __Telegraph__TLMetaConstructor__
#define __Telegraph__TLMetaConstructor__

#import <Foundation/Foundation.h>

#include <memory>
#include <vector>
#include <unordered_map>

#include "TLMetaType.h"
#include "TLMetaField.h"
#include "TLMetaObject.h"
#include "TLConstructedValue.h"

#import "TLSerializationEnvironment.h"
#import "TLSerializationContext.h"

class TLMetaConstructor
{
public:
    int32_t name;
    int32_t signature;
    std::shared_ptr<std::vector<TLMetaField> > fields;
    std::shared_ptr<std::unordered_map<int32_t, int> > fieldNameToIndex;
    std::shared_ptr<TLMetaType> resultType;
    
public:
    TLMetaConstructor(int32_t name, int32_t signature, std::shared_ptr<std::vector<TLMetaField> > fields, std::shared_ptr<TLMetaType> resultType);
    virtual ~TLMetaConstructor();
    
    inline int32_t getName() { return name; }
    inline int32_t getSignature() { return signature; }
    
    inline std::shared_ptr<TLMetaType> getResultType() { return resultType; }
    inline std::shared_ptr<std::vector<TLMetaField> > getFields() { return fields; }
    
    TLConstructedValue construct(NSInputStream *is, id<TLSerializationEnvironment> environment, TLSerializationContext *context, __autoreleasing NSError **error);
    void serialize(NSOutputStream *os, id object);
};

#endif
