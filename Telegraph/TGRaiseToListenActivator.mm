#import "TGRaiseToListenActivator.h"

#import <CoreMotion/CoreMotion.h>
#import <GLKit/GLKit.h>

#import "TGAppDelegate.h"
#import "TGObserverProxy.h"

#import "TGAudioRecorder.h"

#import "TGMusicPlayer.h"

@protocol RaiseManager <NSObject>

- (id)initWithPriority:(int)priority;
- (void)setGestureHandler:(void (^)(int, int))handler;

@end

@interface TGRaiseToListenActivator () {
    TGHolder *_proximityChangeHolder;
    TGObserverProxy *_proximityChangedNotification;

    bool (^_shouldActivate)();
    void (^_activate)();
    void (^_deactivate)();
    
    bool _proximityState;
    TGTimer *_timer;
    
    id _manager;
}

@end

@implementation TGRaiseToListenActivator

- (instancetype)initWithShouldActivate:(bool (^)())shouldActivate activate:(void (^)())activate deactivate:(void (^)())deactivate {
    self = [super init];
    if (self != nil) {
        _shouldActivate = [shouldActivate copy];
        _activate = [activate copy];
        _deactivate = [deactivate copy];
        
        _proximityChangeHolder = [[TGHolder alloc] init];
        _proximityChangedNotification = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(proximityChanged:) name:TGDeviceProximityStateChangedNotification object:nil];
        _enabled = false;
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
    
    [self setEnabled:false];
}

- (void)setEnabled:(bool)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        
        if (enabled) {
            Class c = NSClassFromString(TGEncodeText(@"DNHftuvsfNbobhfs", -1));
            if (c != nil) {
                _manager = [(id<RaiseManager>)[c alloc] initWithPriority:0x2];
                __weak TGRaiseToListenActivator *weakSelf = self;
                [_manager setGestureHandler:^(int arg0, int arg1) {
                    __strong TGRaiseToListenActivator *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGLog(@"gesture %d, %d", arg0, arg1);
                        if (arg0 == 0) {
                            [strongSelf startCheckingProximity];
                        } else if (arg0 == 1) {
                            
                        }
                    }
                }];
            }
        } else {
            [_manager setGestureHandler:nil];
            _manager = nil;
            [self stopCheckingProximity];
            if (_activated) {
                _activated = false;
                if (_deactivate) {
                    _deactivate();
                }
            }
        }
    }
}

- (void)stopCheckingProximity {
    [TGAppDelegateInstance.deviceProximityListeners removeHolder:_proximityChangeHolder];
}

- (bool)shouldActivate {
    if ([TGMusicPlayer isHeadsetPluggedIn]) {
        return false;
    }
    
    if (_shouldActivate) {
        return _shouldActivate();
    }
    
    return true;
}

- (void)startCheckingProximity {
    if (_enabled && [self shouldActivate]) {
        [TGAppDelegateInstance.deviceProximityListeners addHolder:_proximityChangeHolder];
        
        if (_proximityState) {
            _activated = true;
            if (_activate) {
                _activate();
            }
            
            [_timer invalidate];
            _timer = nil;
        } else if (_timer == nil) {
            __weak TGRaiseToListenActivator *weakSelf = self;
            _timer = [[TGTimer alloc] initWithTimeout:1.0 repeat:false completion:^{
                __strong TGRaiseToListenActivator *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_timer = nil;
                    [TGAppDelegateInstance.deviceProximityListeners removeHolder:strongSelf->_proximityChangeHolder];
                }
            } queue:dispatch_get_main_queue()];
            [_timer start];
        }
    }
}

- (void)proximityChanged:(NSNotification *)__unused notification {
    bool proximityState = TGAppDelegateInstance.deviceProximityState;
    TGDispatchOnMainThread(^{
        _proximityState = proximityState;
        
        if (proximityState && _timer != nil) {
            [_timer invalidate];
            _timer = nil;
            _activated = true;
            
            if (_activate) {
                _activate();
            }
        } else if (!proximityState) {
            [_timer invalidate];
            _timer = nil;
            [self stopCheckingProximity];
            
            _activated = false;
            if (_deactivate) {
                _deactivate();
            }
        }
    });
}

@end
