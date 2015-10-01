#import <UIKit/UIKit.h>

#import "TGBotInfo.h"

@class TGModernViewContext;

@interface TGBotConversationHeaderView : UIView

- (instancetype)initWithContext:(TGModernViewContext *)context botInfo:(TGBotInfo *)botInfo;

@end
