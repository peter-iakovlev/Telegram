//
//  GDFileServiceManager.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileServiceManager.h"

#import "GDFileService.h"

#import "GDClientManager.h"
#import "GDRemoteFileServiceSession.h"
#import "GDGoogleDriveFileService.h"

#import "GDAPIToken.h"

static NSString *const GDFileServiceManagerDefaultPersistenceIdentifier = @"GDFileServiceManager";

@interface GDFileServiceManager ()

@property (nonatomic, readonly) dispatch_queue_t private_queue;
@property (nonatomic, copy, readwrite) NSDictionary *keyedFileServices;

@end

@implementation GDFileServiceManager

+ (GDFileServiceManager *)sharedManager
{
    static GDFileServiceManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [GDFileServiceManager new];
        [sharedManager registerKnownFileServices];
    });
    
    return sharedManager;
}

- (void)registerKnownFileServices
{
    static NSArray *knownRemoteFileServiceClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        knownRemoteFileServiceClasses = @[
                                          [GDGoogleDriveFileService class],
                                          ];
    });
    
    for (Class fileServiceClass in knownRemoteFileServiceClasses)
    {
        GDClientManager *clientManager = (GDClientManager *)[[fileServiceClass clientManagerClass] sharedManager];
        GDRemoteFileService *remoteFileService = [(GDRemoteFileService *)[fileServiceClass alloc] initWithClientManager:clientManager];
        if (![clientManager isValid]) continue;
        [self registerFileService:remoteFileService];
        
        Class remoteFileServiceSessionClass = [fileServiceClass fileServiceSessionClass];
        
        for (GDHTTPClient *client in [clientManager allIndependentClients]) {
            GDRemoteFileServiceSession *session = [(GDRemoteFileServiceSession *)[remoteFileServiceSessionClass alloc] initWithFileService:remoteFileService client:client];
            [remoteFileService addFileServiceSession:session];
        }
    }
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    if (self.private_queue) {
        dispatch_release(self.private_queue);
        _private_queue = nil;
    }
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    if ((self = [super init])) {
        self.persistenceIdentifier = GDFileServiceManagerDefaultPersistenceIdentifier;
        _private_queue = dispatch_queue_create("me.grahamdennis.GDFileServiceManager", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - instance methods

- (void)registerFileService:(GDFileService *)fileService
{
    NSParameterAssert(fileService.urlSchemes);
    
    [self _mutateRegisteredFileServices:^(NSMutableDictionary *keyedFileServices) {
        for (NSString *urlScheme in fileService.urlSchemes)
            keyedFileServices[urlScheme] = fileService;
    }];
}

- (void)unregisterFileService:(GDFileService *)fileService
{
    NSParameterAssert(fileService.urlSchemes);
    
    [self _mutateRegisteredFileServices:^(NSMutableDictionary *keyedFileServices) {
        for (NSString *urlScheme in fileService.urlSchemes) {
            [keyedFileServices removeObjectForKey:urlScheme];
        }
    }];
}

- (void)removeAllFileServices
{
    dispatch_sync(self.private_queue, ^{
        self.keyedFileServices = nil;
    });
}

- (void)_mutateRegisteredFileServices:(void (^)(NSMutableDictionary *keyedFileServices))mutationBlock
{
    dispatch_sync(self.private_queue, ^{
        NSMutableDictionary *keyedFileServices = [NSMutableDictionary dictionaryWithDictionary:self.keyedFileServices];
        mutationBlock(keyedFileServices);
        self.keyedFileServices = [keyedFileServices copy];
    });
}

- (GDFileService *)fileServiceForURLScheme:(NSString *)urlScheme
{
    return self.keyedFileServices[urlScheme];
}

- (GDFileServiceSession *)fileServiceSessionForURL:(NSURL *)url
{
    GDFileService *fileService = [self fileServiceForURLScheme:[url scheme]];
    return [fileService fileServiceSessionForURL:url];
}

- (NSArray *)allFileServices
{
    return [[NSSet setWithArray:[self.keyedFileServices allValues]] allObjects];
}

@end
