/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGInstantPreviewTouchAreaView.h"

#import "TGModernConversationCollectionTouchBehaviour.h"

#import "ASHandle.h"
#import "TGTimerTarget.h"

@interface TGInstantPreviewTouchAreaView () <TGModernConversationCollectionTouchBehaviour>
{
    NSTimer *_timer;
}

@property (nonatomic) bool activated;
@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGInstantPreviewTouchAreaView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.exclusiveTouch = true;
    }
    return self;
}

- (void)dealloc
{
    [self invalidateTimer];
}

- (void)willBecomeRecycled
{
    [self invalidateTimer];
    _activated = false;
}

- (void (^)())forwardTouchToCollectionWithCompletion
{
    ASHandle *notificationHanle = _notificationHandle;
    NSString *touchesCompletedAction = _touchesCompletedAction;
    NSDictionary *touchesCompletedOptions = _touchesCompletedOptions;
    
    [self invalidateTimer];
    
    _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(timerEvent) interval:0.1 repeat:false];
    
    __weak TGInstantPreviewTouchAreaView *weakSelf = self;
    return [^
    {
        __strong TGInstantPreviewTouchAreaView *strongSelf = weakSelf;
        [strongSelf invalidateTimer];
        strongSelf.activated = false;
        
        if (touchesCompletedAction != nil)
            [notificationHanle requestAction:touchesCompletedAction options:touchesCompletedOptions];
    } copy];
}

- (bool)scrollingShouldCancelInstantPreview
{
    if (_activated)
    {
        return false;
    }
    
    [self invalidateTimer];
    
    return true;
}

- (void)invalidateTimer
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timerEvent
{
    [self invalidateTimer];
    
    _activated = true;
    
    ASHandle *notificationHanle = _notificationHandle;
    
    if (notificationHanle != nil)
    {
        if (_touchesBeganAction != nil)
            [notificationHanle requestAction:_touchesBeganAction options:_touchesBeganOptions];
    }
}

@end
