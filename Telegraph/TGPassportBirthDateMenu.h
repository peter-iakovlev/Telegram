#import <LegacyComponents/LegacyComponents.h>

@class TGViewController;
@class TGMenuSheetController;

@interface TGPassportBirthDateMenu : NSObject

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController context:(id<LegacyComponentsContext>)context title:(NSString *)title value:(NSDate *)value minValue:(NSDate *)minValue maxValue:(NSDate *)maxValue optional:(bool)optional completed:(void (^)(NSDate *))completed dismissed:(void (^)(void))dismissed sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect;

@end
