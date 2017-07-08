#import <UIKit/UIKit.h>

#import "TGInstantPageLayout.h"
#import "TGInstantPageDisplayView.h"

@class TGConversation;

@interface TGInstantPageChannelView : UIView <TGInstantPageDisplayView>

- (instancetype)initWithFrame:(CGRect)frame channel:(TGConversation *)channel overlay:(bool)overlay presentation:(TGInstantPagePresentation *)presentation;

+ (CGFloat)height;

@end
