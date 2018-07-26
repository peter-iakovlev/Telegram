#import <LegacyComponents/LegacyComponents.h>

@class TGViewController;
@class TGMenuSheetController;

@interface TGPassportGenderMenu : NSObject

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController context:(id<LegacyComponentsContext>)context value:(NSNumber *)value completed:(void (^)(NSNumber *))completed dismissed:(void (^)(void))dismissed sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect;

@end
