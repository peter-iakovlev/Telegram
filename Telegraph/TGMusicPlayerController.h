#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGMusicPlayerController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;
- (void)dismissAnimated:(bool)animated;

@end
