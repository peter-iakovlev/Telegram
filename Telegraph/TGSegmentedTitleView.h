#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGSegmentedTitleView : UIView

@property (nonatomic, copy) void (^segmentChanged)(NSInteger);
@property (nonatomic, readonly) CGFloat innerWidth;

- (instancetype)initWithTitle:(NSString *)title segments:(NSArray *)segments;
- (void)setSegmentedControlHidden:(bool)hidden animated:(bool)animated;

- (void)setPresentation:(TGPresentation *)presentation;

@end
