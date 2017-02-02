#import <UIKit/UIKit.h>
#import "TGOverlayController.h"

@class TGItemPreviewView;

@interface TGItemPreviewController : TGOverlayController

@property (nonatomic, copy) CGPoint (^sourcePointForItem)(id item);
@property (nonatomic, readonly) TGItemPreviewView *previewView;

- (instancetype)initWithParentController:(TGViewController *)parentController previewView:(TGItemPreviewView *)previewView;
- (void)dismiss;
- (void)dismissImmediately;

@end
