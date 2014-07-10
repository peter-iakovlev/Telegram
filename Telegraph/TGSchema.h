/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#define TGSchemaCheckFail { TGLog(@"Error: %s:%d: schema check failed", __PRETTY_FUNCTION__, __LINE__); }

@interface TGSchema : NSObject

+ (NSObject *)makeMutable:(NSObject *)object;
+ (NSString *)stringFromObject:(id)object;
+ (bool)canCreateStringFromObject:(id)object;
+ (int)intFromObject:(id)object;
+ (bool)canCreateIntFromObject:(id)object;
+ (bool)boolFromObject:(id)object;
+ (bool)canCreateBoolFromObject:(id)object;
+ (double)doubleFromObject:(id)object;
+ (bool)canCreateDoubleFromObject:(id)object;
+ (NSArray *)arrayFromObject:(id)object;
+ (bool)canCreateArrayFromObject:(id)object;

+ (NSObject *)checkSchema:(NSObject *)object;

@end
