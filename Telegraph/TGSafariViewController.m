#import "TGSafariViewController.h"

@implementation TGSafariViewController

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    if (self.externalPreviewActionItems != nil)
        return self.externalPreviewActionItems();
    
    return [super previewActionItems];
}

@end
