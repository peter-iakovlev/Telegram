//
//  GDClient.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 31/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDClientManager;
@class GDClientCredential;

@protocol GDClient <NSObject>

- (id)initWithClientManager:(GDClientManager *)clientManager;
- (id)initWithClientManager:(GDClientManager *)clientManager userID:(NSString *)userID;
- (id)initWithClientManager:(GDClientManager *)clientManager credential:(GDClientCredential *)credential;

@property (nonatomic, readonly, strong) GDClientManager *clientManager;
@property (atomic, strong) GDClientCredential *credential;
@property (nonatomic, readonly, getter = isAvailable) BOOL available;

@end
