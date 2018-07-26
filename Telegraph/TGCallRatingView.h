#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGCallRatingView : UIView

@property (nonatomic, readonly) NSString *comment;
@property (nonatomic, readonly) NSInteger selectedStars;
@property (nonatomic, copy) void (^onStarsSelected)(void);
@property (nonatomic, copy) void (^onHeightChanged)(CGFloat height);

- (instancetype)initWithPresentation:(TGPresentation *)presentation;

@end
