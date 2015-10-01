//
//  GDDictionaryBackedObject.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 28/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDDictionaryBackedObject.h"

@implementation GDDictionaryBackedObject

- (id)init
{
    return [self initWithDictionary:@{}];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        _backingStore = [dictionary copy];
    }
    
    return self;
}

#pragma mark - NSCoding

static NSString *const kBackingStoreCoderKey = @"backingStore";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *backingStore = [aDecoder decodeObjectForKey:kBackingStoreCoderKey];
    
    if ((self = [self initWithDictionary:backingStore])) {
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.backingStore forKey:kBackingStoreCoderKey];
}

#pragma mark - Access

- (id)objectForKey:(NSString *)key
{
    return self.backingStore[key];
}

#pragma mark - Debugging

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", [super description], [self.backingStore description]];
}

@end
