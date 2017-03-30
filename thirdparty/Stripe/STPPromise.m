//
//  STPPromise.m
//  Stripe
//
//  Created by Jack Flintermann on 4/20/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPPromise.h"
#import "STPWeakStrongMacros.h"
#import "STPDispatchFunctions.h"


@interface STPPromise<T>()

@property(atomic)T value;
@property(atomic)NSError *error;
@property(atomic)NSArray<STPPromiseValueBlock> *successCallbacks;
@property(atomic)NSArray<STPPromiseErrorBlock> *errorCallbacks;

@end

@implementation STPPromise

+ (instancetype)promiseWithError:(NSError *)error {
    STPPromise *promise = [self new];
    [promise fail:error];
    return promise;
}

+ (instancetype)promiseWithValue:(id)value {
    STPPromise *promise = [self new];
    [promise succeed:value];
    return promise;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _successCallbacks = @[];
        _errorCallbacks = @[];
    }
    return self;
}

- (BOOL)completed {
    return (self.error != nil || self.value != nil);
}

- (void)succeed:(id)value {
    if (self.completed) {
        return;
    }
    self.value = value;
    stpDispatchToMainThreadIfNecessary(^{
        for (STPPromiseValueBlock valueBlock in self.successCallbacks) {
            valueBlock(value);
        }
        self.successCallbacks = nil;
        self.errorCallbacks = nil;
    });
}

- (void)fail:(NSError *)error {
    if (self.completed) {
        return;
    }
    self.error = error;
    stpDispatchToMainThreadIfNecessary(^{
        for (STPPromiseErrorBlock errorBlock in self.errorCallbacks) {
            errorBlock(error);
        }
        self.successCallbacks = nil;
        self.errorCallbacks = nil;
    });
}

- (void)completeWith:(STPPromise *)promise {
    WEAK(self);
    [[promise onSuccess:^(id value) {
        STRONG(self);
        [self succeed:value];
    }] onFailure:^(NSError * _Nonnull error) {
        STRONG(self);
        [self fail:error];
    }];
}

- (instancetype)onSuccess:(STPPromiseValueBlock)callback {
    if (self.value) {
        stpDispatchToMainThreadIfNecessary( ^{
            callback(self.value);
        });
    } else {
        self.successCallbacks = [self.successCallbacks arrayByAddingObject:callback];
    }
    return self;
}

- (instancetype)onFailure:(STPPromiseErrorBlock)callback {
    if (self.error) {
        stpDispatchToMainThreadIfNecessary( ^{
            callback(self.error);
        });
    } else {
        self.errorCallbacks = [self.errorCallbacks arrayByAddingObject:callback];
    }
    return self;
}

- (instancetype)onCompletion:(STPPromiseCompletionBlock)callback {
    return [[self onSuccess:^(id  _Nonnull value) {
        callback(value, nil);
    }] onFailure:^(NSError * _Nonnull error) {
        callback(nil, error);
    }];
}

- (STPPromise<id> *)map:(STPPromiseMapBlock)callback {
    STPPromise<id>* wrapper = [self.class new];
    [[self onSuccess:^(id value) {
        [wrapper succeed:callback(value)];
    }] onFailure:^(NSError *error) {
        [wrapper fail:error];
    }];
    return wrapper;
}


- (STPPromise *)flatMap:(STPPromiseFlatMapBlock)callback {
    STPPromise<id>* wrapper = [self.class new];
    [[self onSuccess:^(id value) {
        STPPromise *internal = callback(value);
        [[internal onSuccess:^(id internalValue) {
            [wrapper succeed:internalValue];
        }] onFailure:^(NSError *internalError) {
            [wrapper fail:internalError];
        }];
    }] onFailure:^(NSError *error) {
        [wrapper fail:error];
    }];
    return wrapper;
}

- (STPVoidPromise *)asVoid {
    STPVoidPromise *voidPromise = [STPVoidPromise new];
    [[self onSuccess:^(__unused id value) {
        [voidPromise succeed];
    }] onFailure:^(NSError * _Nonnull error) {
        [voidPromise fail:error];
    }];
    return voidPromise;
}

@end

@implementation STPVoidPromise

- (void)succeed {
    [self succeed:[NSNull null]];
}

- (void)voidCompleteWith:(STPVoidPromise *)promise {
    WEAK(self);
    [[promise voidOnSuccess:^{
        STRONG(self);
        [self succeed];
    }] onFailure:^(NSError *error) {
        STRONG(self);
        [self fail:error];
    }];
}

- (instancetype)voidOnSuccess:(STPVoidBlock)callback {
    return [super onSuccess:^(__unused id value) {
        if (callback) {
            callback();
        }
    }];
}

- (STPPromise<id> *)voidFlatMap:(STPVoidPromiseFlatMapBlock)block {
    return [super flatMap:^STPPromise *(__unused id value) {
        return block();
    }];
}

- (STPVoidPromise *)asVoid {
    return self;
}

@end
