#import <LegacyComponents/TGMenuSheetButtonItemView.h>

@class TGModernButton;
@class TGPresentation;

@interface TGMenuSheetModernButtonItemView : TGMenuSheetItemView
{
    TGModernButton *_button;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) TGMenuSheetButtonType buttonType;
@property (nonatomic, copy) void(^longPressAction)(void);
@property (nonatomic, copy) void (^action)(void);

@property (nonatomic, strong) TGPresentation *presentation;

- (void)setButtonType:(TGMenuSheetButtonType)buttonType animated:(bool)animated;

- (instancetype)initWithTitle:(NSString *)title type:(TGMenuSheetButtonType)type presentation:(TGPresentation *)presentation action:(void (^)(void))action;

@end

extern const CGFloat TGMenuSheetModernButtonItemViewHeight;
