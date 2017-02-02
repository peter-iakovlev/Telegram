#import "MediaBoxContexts.h"

@implementation MediaResourceStatus

- (_Nonnull instancetype)initWithStatus:(MediaResourceStatusType)status progress:(float)progress {
    self = [super init];
    if (self != nil) {
        _status = status;
        _progress = progress;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[MediaResourceStatus class]] && _status == ((MediaResourceStatus *)object)->_status && _progress == ((MediaResourceStatus *)object)->_progress;
}

@end

@implementation ResourceStatusContext

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _subscribers = [[SBag alloc] init];
    }
    return self;
}

@end

@implementation ResourceData

- (_Nonnull instancetype)initWithPath:(NSString * _Nonnull)path size:(int32_t)size complete:(bool)complete {
    self = [super init];
    if (self != nil) {
        _path = path;
        _size = size;
        _complete = complete;
    }
    return self;
}

@end

@implementation ResourceDataContext

- (_Nonnull instancetype)initWithData:(ResourceData * _Nonnull)data {
    self = [super init];
    if (self != nil) {
        _data = data;
        _completeDataSubscribers = [[SBag alloc] init];
        _fetchSubscribers = [[SBag alloc] init];
    }
    return self;
}

@end

@implementation ResourceStorePaths

- (_Nonnull instancetype)initWithPartial:(NSString * _Nonnull)partial complete:(NSString * _Nonnull)complete {
    self = [super init];
    if (self != nil) {
        _partial = partial;
        _complete = complete;
    }
    return self;
}

@end

@implementation MediaResourceDataFetchResult

- (_Nonnull instancetype)initWithData:(NSData * _Nonnull)data complete:(bool)complete {
    self = [super init];
    if (self != nil) {
        _data = data;
        _complete = complete;
    }
    return self;
}

@end
