#import <UIKit/UIKit.h>
#import "TGChatActionItem.h"

@interface TGChatActionItemView : UIView

- (void)prepareForReuse;
- (void)setItem:(TGChatActionItem *)item;

- (void)setHighlighted:(bool)highlighted animated:(bool)animated;
- (void)setExpanded:(bool)expanded animated:(bool)animated;

@end
