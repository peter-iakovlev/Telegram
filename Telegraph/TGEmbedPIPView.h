#import <UIKit/UIKit.h>

@protocol TGPIPAblePlayerView;

@interface TGEmbedPIPView : UIView

@property (nonatomic, strong) UIView<TGPIPAblePlayerView> *playerView;

@property (nonatomic, copy) void (^switchBackPressed)(void);
@property (nonatomic, copy) void (^closePressed)(void);
@property (nonatomic, copy) void (^arrowPressed)(void);

- (void)setBlurred:(bool)blurred animated:(bool)animated;
- (void)setPanning:(bool)panning;
- (void)setArrowOnRightSide:(bool)flag;

- (void)setControlsHidden:(bool)hidden animated:(bool)animated;

- (void)setClosing;

+ (CGSize)defaultSize;

@end

extern const CGFloat TGEmbedPIPSlipSize;