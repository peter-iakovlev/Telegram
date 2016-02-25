#import <UIKit/UIKit.h>

typedef enum
{
    TGShareToolbarTabNone = 0,
    TGShareToolbarTabCaption = 1 << 0,
    TGShareToolbarTabCrop = 1 << 1,
    TGShareToolbarTabAdjustments = 1 << 2,
    TGShareToolbarTabRotate = 1 << 3
} TGShareToolbarTab;

@interface TGShareToolbarView : UIView

@property (nonatomic, strong) NSString *leftButtonTitle;
@property (nonatomic, strong) NSString *rightButtonTitle;

@property (nonatomic, copy) void (^leftPressed)(void);
@property (nonatomic, copy) void (^rightPressed)(void);

- (void)setHidden:(bool)hidden animated:(bool)animated;

- (void)setRightButtonHidden:(bool)hidden;
- (void)setRightButtonEnabled:(bool)enabled animated:(bool)animated;

- (void)setToolbarTabs:(TGShareToolbarTab)tabs animated:(bool)animated;

@end
