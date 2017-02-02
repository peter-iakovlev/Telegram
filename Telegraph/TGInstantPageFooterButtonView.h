#import <UIKit/UIKit.h>

#import "TGInstantPageDisplayView.h"

@interface TGInstantPageFooterButtonView : UIButton <TGInstantPageDisplayView>

+ (CGFloat)heightForWidth:(CGFloat)width;

@end
