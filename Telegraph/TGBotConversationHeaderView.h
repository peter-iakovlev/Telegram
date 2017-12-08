#import <UIKit/UIKit.h>

#import <LegacyComponents/LegacyComponents.h>

@class TGModernViewContext;

@interface TGBotConversationHeaderView : UIView

- (instancetype)initWithContext:(TGModernViewContext *)context botInfo:(TGBotInfo *)botInfo;

@end
