//
//  GDDictionaryBackedObject.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 28/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDDictionaryBackedObject : NSObject <NSCoding>

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (id)objectForKey:(NSString *)key;

@property (nonatomic, readonly, copy) NSDictionary *backingStore;

@end
