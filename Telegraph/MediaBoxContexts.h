#import <Foundation/Foundation.h>

#import "MediaResource.h"
#import <SSignalKit/SSignalKit.h>

typedef enum {
    MediaResourceStatusRemote,
    MediaResourceStatusLocal,
    MediaResourceStatusFetching
} MediaResourceStatusType;

@interface MediaResourceStatus : NSObject

@property (nonatomic, readonly) MediaResourceStatusType status;
@property (nonatomic, readonly) float progress;

- (_Nonnull instancetype)initWithStatus:(MediaResourceStatusType)status progress:(float)progress;

@end

@interface ResourceStatusContext : NSObject

@property (nonatomic, strong)  MediaResourceStatus * _Nullable status;
@property (nonatomic, strong)  SBag * _Nonnull subscribers;

@end

@interface ResourceData : NSObject

@property (nonatomic, strong, readonly)  NSString * _Nonnull path;
@property (nonatomic, readonly) int32_t size;
@property (nonatomic, readonly) bool complete;

- (_Nonnull instancetype)initWithPath:(NSString * _Nonnull)path size:(int32_t)size complete:(bool)complete;

@end

@interface ResourceDataContext : NSObject

@property (nonatomic, strong) ResourceData * _Nonnull data;
@property (nonatomic, strong) SBag * _Nonnull completeDataSubscribers;
@property (nonatomic, strong) SBag * _Nonnull fetchSubscribers;
@property (nonatomic, strong) id<SDisposable> _Nullable fetchDisposable;

- (_Nonnull instancetype)initWithData:(ResourceData * _Nonnull)data;

@end

@interface ResourceStorePaths : NSObject

@property (nonatomic, strong, readonly) NSString * _Nonnull partial;
@property (nonatomic, strong, readonly) NSString * _Nonnull complete;

- (_Nonnull instancetype)initWithPartial:(NSString * _Nonnull)partial complete:(NSString * _Nonnull)complete;

@end

@interface MediaResourceDataFetchResult : NSObject

@property (nonatomic, strong, readonly) NSData * _Nonnull data;
@property (nonatomic, readonly) bool complete;

- (_Nonnull instancetype)initWithData:(NSData * _Nonnull)data complete:(bool)complete;

@end


