#import <UIKit/UIKit.h>
#import "TGPIPAblePlayerView.h"

@class TGEmbedItemView;
@class TGPIPSourceLocation;

@interface TGEmbedPIPPlaceholderView : UIView

@property (nonatomic, assign) bool invisible;
@property (nonatomic, copy) void(^onWillReattach)(void);

@property (nonatomic, weak) UIView<TGPIPAblePlayerContainerView> *containerView;
@property (nonatomic, strong) TGPIPSourceLocation *location;

- (void)setSolidColor;

- (void)_willReattach;

@end
