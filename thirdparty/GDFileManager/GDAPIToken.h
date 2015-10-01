//
//  GDAPIToken.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 11/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GDAPITokenRegisteredNotification;
extern NSString * const GDAPITokenUnregisteredNotification;

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

@interface GDAPIToken : NSObject <NSCoding>

+ (instancetype)sharedToken;
+ (instancetype)tokenForKey:(NSString *)key;

+ (void)registerToken:(GDAPIToken *)token;
+ (void)unregisterToken:(GDAPIToken *)token;

+ (instancetype)registerTokenWithKey:(NSString *)key secret:(NSString *)secret;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret;

@property (nonatomic, readonly, copy) NSString *key;
@property (nonatomic, readonly, copy) NSString *secret;

@end
