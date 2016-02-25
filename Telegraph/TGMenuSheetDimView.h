#import <UIKit/UIKit.h>

@class TGMenuSheetView;

@interface TGMenuSheetDimView : UIButton

- (instancetype)initWithActionMenuView:(TGMenuSheetView *)menuView;

+ (UIColor *)backgroundColor;

@end
