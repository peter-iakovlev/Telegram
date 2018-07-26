#import "TGCollectionItemView.h"

@class TGConversationSwitchCollectionItemView;
@class TGConversation;

@protocol TGConversationSwitchCollectionItemViewDelegate <NSObject>

@optional

- (void)switchCollectionItemViewChangedValue:(TGConversationSwitchCollectionItemView *)switchItemView isOn:(bool)isOn;

@end

@interface TGConversationSwitchCollectionItemView : TGCollectionItemView

@property (nonatomic, weak) id<TGConversationSwitchCollectionItemViewDelegate> delegate;

- (void)setConversation:(TGConversation *)conversation;
- (void)setFullSeparator:(bool)fullSeparator;
- (void)setIsOn:(bool)isOn animated:(bool)animated;
- (void)setIsEnabled:(bool)isEnabled;

@end
