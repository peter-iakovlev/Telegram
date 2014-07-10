/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGInstantPreviewTouchAreaModel.h"

#import "TGInstantPreviewTouchAreaView.h"

@implementation TGInstantPreviewTouchAreaModel

- (Class)viewClass
{
    return [TGInstantPreviewTouchAreaView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGInstantPreviewTouchAreaView *view = (TGInstantPreviewTouchAreaView *)[self boundView];
    
    view.notificationHandle = _notificationHandle;
    view.touchesBeganAction = _touchesBeganAction;
    view.touchesBeganOptions = _touchesBeganOptions;
    view.touchesCompletedAction = _touchesCompletedAction;
    view.touchesCompletedOptions = _touchesCompletedOptions;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    TGInstantPreviewTouchAreaView *view = (TGInstantPreviewTouchAreaView *)[self boundView];
    
    view.notificationHandle = nil;
    view.touchesBeganAction = nil;
    view.touchesBeganOptions = nil;
    view.touchesCompletedAction = nil;
    view.touchesCompletedOptions = nil;
    
    [super unbindView:viewStorage];
}

- (void)setTouchesBeganAction:(NSString *)touchesBeganAction
{
    _touchesBeganAction = touchesBeganAction;
    
    ((TGInstantPreviewTouchAreaView *)[self boundView]).touchesBeganAction = touchesBeganAction;
}

- (void)setTouchesCompletedAction:(NSString *)touchesCompletedAction
{
    _touchesCompletedAction = touchesCompletedAction;
    
    ((TGInstantPreviewTouchAreaView *)[self boundView]).touchesCompletedAction = touchesCompletedAction;
}

@end
