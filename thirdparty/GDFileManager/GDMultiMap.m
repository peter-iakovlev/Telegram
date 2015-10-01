//
//  GDMultiMap.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 14/09/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDMultiMap.h"

@interface GDMultiMap ()

@property (nonatomic, strong, readonly) NSMutableDictionary *dictionary;

@end

@implementation GDMultiMap

- (id)init
{
    if ((self = [super init])) {
        _dictionary = [NSMutableDictionary new];
    }
    return self;
}

- (void)addObject:(id)object forKey:(id<NSCopying>)key
{
    if (!key) return;
    NSMutableSet *set = self.dictionary[key];
    if (!set) {
        set = [NSMutableSet new];
        self.dictionary[key] = set;
    }
    [set addObject:object];
}

- (void)removeObject:(id)object forKey:(id<NSCopying>)key
{
    if (!key || !object) return;
    NSMutableSet *set = self.dictionary[key];
    [set removeObject:object];
}

- (NSSet *)objectsForKey:(id)key
{
    if (!key) return nil;
    NSMutableSet *set = self.dictionary[key];
    return [set copy];
}

- (void)removeAllObjects
{
    [self.dictionary removeAllObjects];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id, id, BOOL *))block
{
    if (!block) return;
    
    __block BOOL stop = NO;
    [self.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableSet *values, BOOL *stopPtr) {
        for (id value in values) {
            block(key, value, &stop);
            if (stop) {
                *stopPtr = YES;
                return;
            }
        }
    }];
}

@end
