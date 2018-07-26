#import <LegacyComponents/LegacyComponents.h>

@interface TGProxyButtonItemView : TGMenuSheetButtonItemView

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(TGProxyButtonItemView *))action;

- (void)setConnecting;
- (void)setFailed;

@end
