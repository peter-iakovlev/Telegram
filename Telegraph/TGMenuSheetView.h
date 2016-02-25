#import <UIKit/UIKit.h>

@interface TGMenuSheetView : UIView

@property (nonatomic, readonly) NSArray *itemViews;

@property (nonatomic, readonly) UIEdgeInsets edgeInsets;
@property (nonatomic, readonly) CGFloat interSectionSpacing;

@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, readonly) CGFloat menuHeight;
@property (nonatomic, readonly) CGSize menuSize;

@property (nonatomic, readonly) NSValue *mainFrame;
@property (nonatomic, readonly) NSValue *headerFrame;
@property (nonatomic, readonly) NSValue *footerFrame;

@property (nonatomic, copy) bool (^tapDismissalAllowed)(void);

@property (nonatomic, copy) void (^menuRelayout)(void);

- (instancetype)initWithItemViews:(NSArray *)itemViews sizeClass:(UIUserInterfaceSizeClass)sizeClass;

- (void)menuWillAppearAnimated:(bool)animated;
- (void)menuDidAppearAnimated:(bool)animated;
- (void)menuWillDisappearAnimated:(bool)animated;
- (void)menuDidDisappearAnimated:(bool)animated;

- (void)updateTraitsWithSizeClass:(UIUserInterfaceSizeClass)sizeClass;

@end

extern const CGFloat TGMenuSheetCornerRadius;
extern const bool TGMenuSheetUseEffectView;
