//
//  GDFileManagerConstants.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 18/08/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#ifndef GDFileManagerExample_GDFileManagerConstants_h
#define GDFileManagerExample_GDFileManagerConstants_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GDFileManagerCachePolicy) {
    GDFileManagerReturnCacheDataElseDontLoad = 0,
    GDFileManagerReturnCacheDataElseLoad,
    GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOffline, // default
    GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOfflineAndIgnoreSessionCache
};

typedef NS_OPTIONS(NSUInteger, GDFileManagerUploadOptions) {
    GDFileManagerUploadDeleteOnSuccess = 1 << 0,
    GDFileManagerUploadNewVersionsCancelOld = 1 << 2
};

typedef NS_ENUM(NSUInteger, GDFileManagerErrorCode) {
    GDFileManagerRootNotUniqueError = 4,
    GDFileManagerFileSessionsNotIdenticalError = 20,
    GDFileManagerUserIDChangedError = 100,
    GDFileManagerNoCanonicalURLError = 101,
    GDFileManagerNotDirectoryError = 102,
    GDFileManagerNoResultInCacheError = 103,
    GDFileManagerNoDataCacheCoordinatorError = 104,
    GDFileManagerNoLocalURLError = 105,
    GDFileManagerLocalURLNotFileURLError = 106,
    GDFileManagerCantReadFromLocalURLError = 107,
    GDFileManagerLoginCancelledError = 200,
    GDFileManagerNetworkUnreachableError = 300,
    GDFileManagerServiceIsReadOnlyError = 403,
    GDFileManagerFileDeletedError = 407,
    GDFileManagerUnsupportedOperationError = 413,
};

extern __attribute__((overloadable)) NSError *GDFileManagerError(NSInteger code, NSError *underlyingError);
extern __attribute__((overloadable)) NSError *GDFileManagerError(NSInteger code);

#endif
