#import <UIKit/UIKit.h>
#import <LegacyComponents/LegacyComponentsContext.h>

@class TGPresentation;

@interface TGMusicPlayerFullView : UIView

@property (nonatomic, copy) void (^actionsPressed)(void);
@property (nonatomic, copy) void (^dismissed)(void);

@property (nonatomic, readonly) UIButton *actionsButton;
@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

- (instancetype)initWithFrame:(CGRect)frame context:(id<LegacyComponentsContext>)context presentation:(TGPresentation *)presentation;

- (void)dismissAnimated:(bool)animated completion:(void (^)(void))completion;

@end
