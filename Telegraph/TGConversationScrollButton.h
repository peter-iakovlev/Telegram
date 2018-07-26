#import <LegacyComponents/TGModernButton.h>

@class TGPresentation;

@interface TGConversationScrollButton : TGModernButton

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic) NSInteger badgeCount;

- (instancetype)initWithMentions:(bool)mentions;

@end
