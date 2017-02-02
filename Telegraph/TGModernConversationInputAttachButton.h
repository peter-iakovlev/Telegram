#import "TGModernButton.h"

@protocol TGModernConversationInputAttachButtonDelegate <NSObject>

@optional

- (void)attachButtonInteractionBegan;
- (void)attachButtonInteractionUpdate:(CGPoint)location;
- (void)attachButtonInteractionCompleted:(CGPoint)location;

@end

@interface TGModernConversationInputAttachButton : TGModernButton

@property (nonatomic, weak) id<TGModernConversationInputAttachButtonDelegate> delegate;

@end
