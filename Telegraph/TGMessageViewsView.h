#import <UIKit/UIKit.h>
#import "TGModernView.h"

#import "TGMessageViewsViewModel.h"

#import "TGPresentation.h"

@interface TGMessageViewsView : UIView <TGModernView>

@property (nonatomic) int32_t count;
@property (nonatomic, strong) TGPresentation *presentation;

- (void)setType:(TGMessageViewsViewType)type;

+ (NSString *)stringForCount:(int32_t)count;
+ (void)drawInContext:(CGContextRef)__unused context frame:(CGRect)frame type:(TGMessageViewsViewType)type count:(int32_t)count presentation:(TGPresentation *)presentation;

@end
