#import <UIKit/UIKit.h>

@interface TGCallRatingView : UIView

@property (nonatomic, readonly) NSInteger selectedStars;
@property (nonatomic, copy) void (^onStarsSelected)(void);

@end
