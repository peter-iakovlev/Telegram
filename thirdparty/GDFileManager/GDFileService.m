//
//  GDFileService.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileService.h"
#import "GDFileServiceSession.h"
#import "GDURLMetadata.h"

@interface GDFileService ()

@property (nonatomic, copy) NSDictionary *keyedFileServiceSessions;
@property (nonatomic, readwrite) dispatch_queue_t isolationQueue;
@property (nonatomic, readwrite) dispatch_queue_t workQueue;

@end

@implementation GDFileService

+ (Class)fileServiceSessionClass
{
    NSParameterAssert(NO);
    return nil;
}

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    if (self.isolationQueue) {
        dispatch_release(self.isolationQueue);
        self.isolationQueue = NULL;
    }
    if (self.workQueue) {
        dispatch_release(self.workQueue);
        self.workQueue = NULL;
    }
}
#endif

- (id)init
{
    if ((self = [super init])) {
        self.keyedFileServiceSessions = [NSDictionary new];
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    NSString *label = [NSString stringWithFormat:@"%@.isolation.%p", [self class], self];
    self.isolationQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
    
    label = [NSString stringWithFormat:@"%@.work.%p", [self class], self];
    self.workQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_CONCURRENT);
}

#pragma mark - NSCoding

static NSString *const kFileServiceSessionsCoderKey = @"keyedFileServiceSessions";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.keyedFileServiceSessions = [aDecoder decodeObjectForKey:kFileServiceSessionsCoderKey];
        
        [self _commonInit];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.keyedFileServiceSessions forKey:kFileServiceSessionsCoderKey];
}

#pragma mark - Service description

- (NSArray *)urlSchemes
{
    return @[[self urlScheme]];
}

- (NSString *)urlScheme
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)shouldCacheResults
{
    return YES;
}

#pragma mark - Session

- (NSString *)keyForFileServiceURL:(NSURL *)fileServiceURL
{
    NSString *key = (__bridge_transfer NSString *)CFURLCopyNetLocation((__bridge CFURLRef)fileServiceURL);
    return key;
}

- (void)addFileServiceSession:(GDFileServiceSession *)fileServiceSession
{
    NSParameterAssert(fileServiceSession.baseURL);
    NSString *key = [self keyForFileServiceURL:fileServiceSession.baseURL];
    [self _mutateKeyedFileServiceSessions:^(NSMutableDictionary *keyedFileServiceSessions) {
        keyedFileServiceSessions[key] = fileServiceSession;
    }];
}

- (void)removeFileServiceSession:(GDFileServiceSession *)fileServiceSession
{
    NSParameterAssert(fileServiceSession.baseURL);
    NSString *key = [self keyForFileServiceURL:fileServiceSession.baseURL];
    [self _mutateKeyedFileServiceSessions:^(NSMutableDictionary *keyedFileServiceSessions) {
        [keyedFileServiceSessions removeObjectForKey:key];
    }];
}

- (void)_mutateKeyedFileServiceSessions:(void (^)(NSMutableDictionary *keyedFileServiceSessions))mutationBlock
{
    dispatch_sync(self.isolationQueue, ^{
        NSMutableDictionary *mutableKeyedFileServiceSessions = [NSMutableDictionary dictionaryWithDictionary:self.keyedFileServiceSessions];
        mutationBlock(mutableKeyedFileServiceSessions);
        self.keyedFileServiceSessions = [mutableKeyedFileServiceSessions copy];
    });
}

- (GDFileServiceSession *)fileServiceSessionForURL:(NSURL *)url
{
    NSParameterAssert(url);
    
    NSString *key = [self keyForFileServiceURL:url];
    return self.keyedFileServiceSessions[key];
}

- (NSArray *)fileServiceSessions
{
    return [self.keyedFileServiceSessions allValues];
}

#pragma mark - Linking

- (BOOL)handleOpenURL:(NSURL *)__unused url
{
    return NO;
}

- (void)linkFromController:(UIViewController *)__unused rootController
                   success:(void (^)(GDFileServiceSession *fileServiceSession))__unused success
                   failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)unlinkSession:(GDFileServiceSession *)session
{
    [self removeFileServiceSession:session];
}

#pragma mark - Presentation

- (UIImage *)logoImage
{
    return nil;
}

- (UIImage *)iconImage
{
    return nil;
}

- (NSString *)name
{
    return nil;
}


@end
