#import "TGNavigationBarMusicPlayerProvider.h"

#import "TGMusicPlayerView.h"

#import "TGTelegraph.h"

@implementation TGNavigationBarMusicPlayerProvider

- (UIView<TGNavigationBarMusicPlayerView> *)makeMusicPlayerView:(UINavigationController *)navigationController {
    return [[TGMusicPlayerView alloc] initWithNavigationController:navigationController];
}

- (SSignal *)musicPlayerIsActive {
    return [[[TGTelegraphInstance musicPlayer] playingStatus] map:^id(TGMusicPlayerStatus *status) {
        return @(status != nil);
    }];
}

@end
