/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef __Telegraph__TLMetaType__
#define __Telegraph__TLMetaType__

#include <Foundation/Foundation.h>

#include <memory>
#include <vector>

typedef enum {
    TLMetaTypeCategoryObject = 0,
    TLMetaTypeCategoryBuiltinInt32 = 1,
    TLMetaTypeCategoryBuiltinInt64 = 2,
    TLMetaTypeCategoryBuiltinInt128 = 3,
    TLMetaTypeCategoryBuiltinInt256 = 4,
    TLMetaTypeCategoryBuiltinString = 5,
    TLMetaTypeCategoryBuiltinBytes = 6,
    TLMetaTypeCategoryBuiltinDouble = 7,
    TLMetaTypeCategoryBuiltinBool = 8,
    TLMetaTypeCategoryBuiltinVector = 9
} TLMetaTypeCategory;

class TLMetaType;

struct TLMetaTypeArgument
{
    bool boxed;
    int32_t unboxedConstructorSignature;
    int32_t unboxedConstructorName;
    
    std::shared_ptr<TLMetaType> type;
};

class TLMetaType
{
private:
    int32_t name;
    TLMetaTypeCategory category;
    
    std::vector<TLMetaTypeArgument> arguments;
    
public:
    TLMetaType(int32_t name, TLMetaTypeCategory category, std::vector<TLMetaTypeArgument> const &arguments);
    virtual ~TLMetaType();
    
    inline int32_t getName() { return name; }
    inline int32_t getCategory() { return category; }
    inline std::vector<TLMetaTypeArgument> &getArguments() { return arguments; }
};

#endif
