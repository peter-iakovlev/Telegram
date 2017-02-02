#import <Foundation/Foundation.h>

@class TGViewController;
@class TGMenuSheetController;
@class TGWebPageMediaAttachment;
@class TGLocationMediaAttachment;
@class TGMenuSheetController;

@interface TGOpenInMenu : NSObject

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController title:(NSString *)title url:(NSURL *)url buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction
 sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem;

+ (bool)hasThirdPartyAppsForURL:(NSURL *)url;

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController title:(NSString *)title webPageAttachment:(TGWebPageMediaAttachment *)attachment buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem;

+ (bool)hasThirdPartyAppsForWebPageAttachment:(TGWebPageMediaAttachment *)attachment;

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController title:(NSString *)title locationAttachment:(TGLocationMediaAttachment *)attachment directions:(bool)directions buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem;

+ (bool)hasThirdPartyAppsForLocationAttachment:(TGLocationMediaAttachment *)attachment directions:(bool)directions;

@end
