#import "TGOverlayControllerWindow.h"

#import "TGArchivedStickerPacksAlertView.h"
#import "TGPaymentAlertView.h"

@interface TGPaymentAlert : TGOverlayControllerWindow

@property (nonatomic, strong, readonly) TGPaymentAlertView *view;

- (instancetype)initWithParentController:(TGViewController *)parentController text:(NSString *)text;

@end
