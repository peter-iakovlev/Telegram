/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef __Telegraph__TLMetaObject__
#define __Telegraph__TLMetaObject__

#import <Foundation/Foundation.h>

#include "TLMetaField.h"
#include "TLConstructedValue.h"

#include <memory>
#include <vector>
#include <unordered_map>

class TLMetaObject
{
public:
    std::shared_ptr<std::vector<TLMetaField> > fields;
    std::shared_ptr<std::unordered_map<int32_t, int> > fieldNameToIndex;
    std::shared_ptr<std::vector<TLConstructedValue> > values;
    
public:
    TLMetaObject(std::shared_ptr<std::vector<TLMetaField> > fields, std::shared_ptr<std::unordered_map<int32_t, int> > fieldNameToIndex, std::shared_ptr<std::vector<TLConstructedValue> > values);
    TLMetaObject(const TLMetaObject &other);
    TLMetaObject & operator= (const TLMetaObject &other);
    virtual ~TLMetaObject();
    
    int32_t getInt32(int32_t name);
    int64_t getInt64(int32_t name);
    bool getBool(int32_t name);
    double getDouble(int32_t name);
    NSString *getString(int32_t name);
    NSData *getBytes(int32_t name);
    NSArray *getArray(int32_t name);
    id getObject(int32_t name);
};

#endif
