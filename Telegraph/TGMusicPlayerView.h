#import <UIKit/UIKit.h>

#import <LegacyComponents/LegacyComponents.h>

#import "TGMusicPlayer.h"

@interface TGMusicPlayerView : UIView <TGNavigationBarMusicPlayerView>

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

- (void)setStatus:(TGMusicPlayerStatus *)status;

@end
