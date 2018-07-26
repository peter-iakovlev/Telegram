#import <LegacyComponents/LegacyComponents.h>

@interface TGProxyBarButton : TGModernButton

@property (nonatomic) CGPoint portraitAdjustment;
@property (nonatomic) CGPoint landscapeAdjustment;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *spinner;

- (void)setSpinning:(bool)spinning;

@end
