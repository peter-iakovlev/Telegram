#import <UIKit/UIKit.h>

@interface TGCallRatingView : UIView

@property (nonatomic, readonly) NSString *comment;
@property (nonatomic, readonly) NSInteger selectedStars;
@property (nonatomic, copy) void (^onStarsSelected)(void);
@property (nonatomic, copy) void (^onHeightChanged)(CGFloat height);

@end
