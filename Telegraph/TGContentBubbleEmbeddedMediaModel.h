#import "TGModernViewModel.h"

@interface TGContentBubbleEmbeddedMediaModel : TGModernViewModel

@property (nonatomic, copy) void (^downloadMedia)();
@property (nonatomic, copy) void (^openMedia)();

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage delayDisplay:(bool)delayDisplay;
- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated;

@end
