#import "TGMenuSheetButtonItemView.h"

@interface TGCallAudioRouteButtonItemView : TGMenuSheetButtonItemView

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon selected:(bool)selected action:(void (^)(void))action;

@end
