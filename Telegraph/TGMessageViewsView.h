#import <UIKit/UIKit.h>
#import "TGModernView.h"

#import "TGMessageViewsViewModel.h"

@interface TGMessageViewsView : UIView <TGModernView>

@property (nonatomic) int32_t count;

- (void)setType:(TGMessageViewsViewType)type;

+ (NSString *)stringForCount:(int32_t)count;
+ (void)drawInContext:(CGContextRef)__unused context frame:(CGRect)frame type:(TGMessageViewsViewType)type count:(int32_t)count;

@end
