#import <LegacyComponents/TGModernButton.h>

@interface TGConversationScrollButton : TGModernButton

@property (nonatomic) NSInteger badgeCount;

- (instancetype)initWithMentions:(bool)mentions;

@end
