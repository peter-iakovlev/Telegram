#import "TGModernConversationTitlePanel.h"

@interface TGLiveLocationTitlePanel : TGModernConversationTitlePanel

@property (nonatomic, copy) void (^tapped)();
@property (nonatomic, copy) void (^closed)();

@property (nonatomic, readonly) UIButton *closeButton;

- (void)setLiveLocations:(NSArray *)liveLocations;
- (void)setSessions:(NSArray *)sessions;

@end
