#import "TGModernTemporaryView.h"

#import "TGModernConversationItem.h"
#import "TGModernViewModel.h"

@implementation TGModernTemporaryView

- (void)unbindItems
{
    for (TGModernConversationItem *item in _boundItems)
    {
        [item.viewModel unbindView:_viewStorage];
    }
    
    _boundItems = nil;
}

- (void)dealloc
{
    [self unbindItems];
}

@end
