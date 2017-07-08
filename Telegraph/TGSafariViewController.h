#import <SafariServices/SafariServices.h>

@interface TGSafariViewController : SFSafariViewController

@property (nonatomic, copy) NSArray<id<UIPreviewActionItem>> *(^externalPreviewActionItems)(void);

@end
