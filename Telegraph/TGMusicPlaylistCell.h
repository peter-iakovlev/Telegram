#import <UIKit/UIKit.h>

@class TGMusicPlayerItem;

@interface TGMusicPlaylistCell : UICollectionViewCell

@property (nonatomic, strong) TGMusicPlayerItem *item;

- (void)setCurrent:(bool)current;
- (void)setPlaying:(bool)playing;

@end

extern NSString *const TGMusicPlaylistCellKind;
extern const CGFloat TGMusicPlaylistCellHeight;
