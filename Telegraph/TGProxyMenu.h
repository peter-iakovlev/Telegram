#import <Foundation/Foundation.h>
#import "TGProxyItem.h"

@class TGViewController;
@class TGMenuSheetController;

@interface TGProxyMenu : NSObject

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController proxy:(TGProxyItem *)proxy sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect;

@end
