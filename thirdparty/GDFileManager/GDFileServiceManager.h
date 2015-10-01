//
//  GDFileServiceManager.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDFileService;
@class GDFileServiceSession;
@class GDAPIToken;

@interface GDFileServiceManager : NSObject

+ (GDFileServiceManager *)sharedManager;

- (void)registerFileService:(GDFileService *)fileService;
- (void)unregisterFileService:(GDFileService *)fileService;
- (void)removeAllFileServices;

- (GDFileService *)fileServiceForURLScheme:(NSString *)urlScheme;
- (GDFileServiceSession *)fileServiceSessionForURL:(NSURL *)url;

- (NSArray *)allFileServices;

@property (nonatomic, strong) NSString *persistenceIdentifier;

@end
