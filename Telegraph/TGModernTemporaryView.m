#import "TGModernTemporaryView.h"

#import "TGModernConversationItem.h"
#import "TGModernViewModel.h"

@implementation TGModernTemporaryView

- (void)dealloc
{
    for (TGModernConversationItem *item in _boundItems)
    {
        [item.viewModel unbindView:_viewStorage];
    }
}

@end
