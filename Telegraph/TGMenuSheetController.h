#import "TGMenuSheetButtonItemView.h"

@interface TGMenuSheetController : UIViewController

@property (nonatomic, assign) bool requiuresDimView;
@property (nonatomic, assign) bool dismissesByOutsideTap;
@property (nonatomic, assign) bool hasSwipeGesture;

@property (nonatomic, readonly) NSArray *itemViews;

@property (nonatomic, copy) void (^didDismiss)(bool manual);

- (instancetype)initWithItemViews:(NSArray *)itemViews;
- (void)setItemViews:(NSArray *)itemViews;
- (void)setItemViews:(NSArray *)itemViews animated:(bool)animated;

- (void)presentInViewController:(UIViewController *)viewController sourceView:(UIView *)sourceView animated:(bool)animated;
- (void)dismissAnimated:(bool)animated;
- (void)dismissAnimated:(bool)animated manual:(bool)manual;

@end
