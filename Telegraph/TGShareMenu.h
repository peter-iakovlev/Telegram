#import <Foundation/Foundation.h>

@class TGViewController;
@class TGMenuSheetController;

@interface TGShareMenu : NSObject

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction shareAction:(void (^)(NSArray *peerIds, NSString *caption))shareAction externalShareItemSignal:(id)externalShareItemSignal sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem;

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController topButtonTitle:(NSString *)topButtonTitle topButtonAction:(void (^)(void))topButtonAction bottomButtonTitle:(NSString *)bottomButtonTitle bottomButtonAction:(void (^)(void))bottomButtonAction shareAction:(void (^)(NSArray *peerIds, NSString *caption))shareAction externalShareItemSignal:(id)externalShareItemSignal sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem;

@end
