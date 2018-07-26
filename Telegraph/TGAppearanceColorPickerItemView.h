#import <LegacyComponents/LegacyComponents.h>

@interface TGAppearanceColorPickerItemView : TGMenuSheetItemView

@property (nonatomic, copy) void (^colorSelected)(UIColor *color);

- (instancetype)initWithCurrentColor:(UIColor *)currentColor;

@end
