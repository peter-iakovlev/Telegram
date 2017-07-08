#import <UIKit/UIKit.h>

#import "TGInstantPageLayout.h"
#import "TGInstantPageDisplayView.h"

@interface TGInstantPageFooterButtonView : UIButton <TGInstantPageDisplayView>

- (instancetype)initWithFrame:(CGRect)frame presentation:(TGInstantPagePresentation *)presentation;

+ (CGFloat)heightForWidth:(CGFloat)width;

@end
