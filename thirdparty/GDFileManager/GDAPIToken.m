//
//  GDAPIToken.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 11/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDAPIToken.h"

static NSDictionary *tokenMap = nil;
static dispatch_queue_t token_map_queue = nil;

NSString *const GDAPITokenRegisteredNotification;
NSString *const GDAPITokenUnregisteredNotification;

@implementation GDAPIToken

#pragma mark - Class Support methods

+ (void)initialize
{
    if (self == [GDAPIToken class]) {
        tokenMap = [NSDictionary new];
        token_map_queue = dispatch_queue_create("me.grahamdennis.token_map_queue", DISPATCH_QUEUE_SERIAL);
    }
}

+ (NSArray *)tokensForClass
{
    return [tokenMap objectForKey:NSStringFromClass([self class])];
}

+ (instancetype)sharedToken
{
    NSArray *tokens = [self tokensForClass];
    if ([tokens count] == 0) return nil;
    return [tokens objectAtIndex:0];
}

+ (instancetype)tokenForKey:(NSString *)key
{
    NSArray *tokens = [self tokensForClass];
    for (GDAPIToken *token in tokens) {
        if ([token.key isEqualToString:key])
            return token;
    }
    
    return nil;
}

+ (void)registerToken:(GDAPIToken *)token
{
    NSParameterAssert(token);
    
    [self _mutateTokenMapForToken:token mutationBlock:^(NSMutableArray *tokens) {
        [tokens removeObject:token];
        [tokens insertObject:token atIndex:0];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GDAPITokenRegisteredNotification object:token];
}

+ (void)unregisterToken:(GDAPIToken *)token
{
    NSParameterAssert(token);
    
    [self _mutateTokenMapForToken:token mutationBlock:^(NSMutableArray *tokens) {
        [tokens removeObject:token];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GDAPITokenUnregisteredNotification object:token];
}

+ (void)_mutateTokenMapForToken:(GDAPIToken *)token mutationBlock:(void (^)(NSMutableArray *tokens))mutationBlock
{
    dispatch_sync(token_map_queue, ^{
        NSMutableArray *tokens = [NSMutableArray arrayWithArray:[[token class] tokensForClass]];
        mutationBlock(tokens);
        NSMutableDictionary *mutableTokenMap = [tokenMap mutableCopy];
        [mutableTokenMap setObject:[tokens copy] forKey:NSStringFromClass([token class])];
        tokenMap = [mutableTokenMap copy];
    });
}

+ (instancetype)registerTokenWithKey:(NSString *)key secret:(NSString *)secret
{
    GDAPIToken *apiToken = [[[self class] alloc] initWithKey:key secret:secret];
    [[self class] registerToken:apiToken];
    return apiToken;
}

#pragma mark - Instance methods

- (id)initWithKey:(NSString *)key secret:(NSString *)secret
{
    if ((self = [super init]))
    {
        _key = key;
        _secret = secret;
        
    }

    GDAPIToken *apiToken = [[self class] tokenForKey:key];
    if (apiToken && [apiToken isEqual:self]) {
        return apiToken;
    }

    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[GDAPIToken class]]
        && [self.key isEqualToString:[(GDAPIToken *)object key]]
        && [self.secret isEqualToString:[(GDAPIToken *)object secret]])
        return YES;
    return NO;
}

- (NSUInteger)hash
{
    return NSUINTROTATE([self.key hash], NSUINT_BIT/4) ^ [self.secret hash];
}

#pragma mark - NSCoding

static NSString *const kAPITokenClassCoderKey = @"apiTokenClass";
static NSString *const kAPITokenKeyCoderKey = @"apiTokenKey";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *apiTokenClassName = [aDecoder decodeObjectForKey:kAPITokenClassCoderKey];
    Class apiTokenClass = NSClassFromString(apiTokenClassName);
    NSString *apiTokenKey = [aDecoder decodeObjectForKey:kAPITokenKeyCoderKey];
    
    return [apiTokenClass tokenForKey:apiTokenKey];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:NSStringFromClass([self class]) forKey:kAPITokenClassCoderKey];
    [aCoder encodeObject:self.key forKey:kAPITokenKeyCoderKey];
}

@end
