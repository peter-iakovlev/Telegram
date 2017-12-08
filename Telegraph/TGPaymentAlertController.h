#import <LegacyComponents/LegacyComponents.h>

#import "TGArchivedStickerPacksAlertView.h"
#import "TGPaymentAlertView.h"

@interface TGPaymentAlert : TGOverlayControllerWindow

@property (nonatomic, strong, readonly) TGPaymentAlertView *view;

- (instancetype)initWithManager:(id<LegacyComponentsOverlayWindowManager>)manager parentController:(TGViewController *)parentController text:(NSString *)text;

@end
