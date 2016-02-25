#import <UIKit/UIKit.h>

@class TGMenuSheetView;

typedef enum
{
    TGMenuSheetItemTypeDefault,
    TGMenuSheetItemTypeHeader,
    TGMenuSheetItemTypeFooter
} TGMenuSheetItemType;

@interface TGMenuSheetItemView : UIView
{
    CGFloat _screenHeight;
    UIUserInterfaceSizeClass _sizeClass;
}

@property (nonatomic, readonly) TGMenuSheetItemType type;

- (instancetype)initWithType:(TGMenuSheetItemType)type;

- (void)setHidden:(bool)hidden animated:(bool)animated;

@property (nonatomic, readonly) CGFloat contentHeightCorrection;
- (CGFloat)preferredHeightForWidth:(CGFloat)width screenHeight:(CGFloat)screenHeight;

@property (nonatomic, assign) bool requiresDivider;

@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) UIUserInterfaceSizeClass sizeClass;

@property (nonatomic, copy) void (^layoutUpdateBlock)(void);
- (void)requestMenuLayoutUpdate;

@property (nonatomic, copy) void (^highlightUpdateBlock)(bool highlighted);

- (void)menuView:(TGMenuSheetView *)menuView willAppearAnimated:(bool)animated;
- (void)menuView:(TGMenuSheetView *)menuView didAppearAnimated:(bool)animated;
- (void)menuView:(TGMenuSheetView *)menuView willDisappearAnimated:(bool)animated;
- (void)menuView:(TGMenuSheetView *)menuView didDisappearAnimated:(bool)animated;

@end
