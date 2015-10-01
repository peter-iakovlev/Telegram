#import <UIKit/UIKit.h>

#import "TGMusicPlayer.h"

@interface TGMusicPlayerView : UIView

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

- (void)setStatus:(TGMusicPlayerStatus *)status;

@end
