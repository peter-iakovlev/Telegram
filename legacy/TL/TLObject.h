/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "NSOutputStream+TL.h"
#import "NSInputStream+TL.h"

#ifdef __cplusplus
#include "TLMetaObject.h"
#include <map>
#endif

#import "TLSerializationEnvironment.h"

//#define TL_LOG_SERIALIZATION

@protocol TLObject <NSObject>

@required

- (int32_t)TLconstructorSignature;
- (int32_t)TLconstructorName;

#ifdef __cplusplus
- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject;
- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values;
#endif

@optional

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)context error:(__autoreleasing NSError **)error;
- (void)TLserialize:(NSOutputStream *)os;

@end

@protocol TLVector <TLObject>

@required

- (id)TLvectorConstruct;

@end

@interface NSArray (TL)

- (void)TLtagConstructorName:(int32_t)constructorName;
- (int32_t)TLconstructorName;

@end
