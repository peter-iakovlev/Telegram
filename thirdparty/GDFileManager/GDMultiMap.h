//
//  GDMultiMap.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 14/09/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDMultiMap : NSObject

- (void)addObject:(id)object forKey:(id <NSCopying>)key;
- (void)removeObject:(id)object forKey:(id <NSCopying>)key;
- (NSSet *)objectsForKey:(id)key;
- (void)removeAllObjects;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id object, BOOL *stop))block;

@end
