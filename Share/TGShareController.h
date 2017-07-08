#import <UIKit/UIKit.h>

@class TGShareToolbarView;

@interface TGShareController : UINavigationController

- (void)sendToPeers:(NSArray *)peers models:(NSArray *)models caption:(NSString *)caption;
- (void)dismissForCancel:(bool)forCancel;

@end
