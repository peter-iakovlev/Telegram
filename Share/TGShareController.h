#import <UIKit/UIKit.h>

@class TGShareToolbarView;

@interface TGShareController : UINavigationController

@property (nonatomic, readonly, strong) TGShareToolbarView *toolbarView;

- (void)sendToPeers:(NSArray *)peers models:(NSArray *)models;
- (void)dismissForCancel:(bool)forCancel;

@end
