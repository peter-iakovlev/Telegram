#import <UIKit/UIKit.h>

@class TGMusicPlayerItem;
@class TGPresentation;

@interface TGMusicPlaylistCell : UICollectionViewCell

@property (nonatomic, strong) TGMusicPlayerItem *item;
@property (nonatomic, strong) TGPresentation *presentation;

- (void)setCurrent:(bool)current;
- (void)setPlaying:(bool)playing;

@end

extern NSString *const TGMusicPlaylistCellKind;
extern const CGFloat TGMusicPlaylistCellHeight;
