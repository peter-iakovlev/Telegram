#import "TGImageView.h"

#import "TGModernView.h"

#import <SSignalKit/SSignalKit.h>

@interface TGSignalImageView : TGImageView <TGModernView>

@property (nonatomic) CGRect transitionContentRect;

- (void)setVideoPathSignal:(SSignal *)videoPathSignal;

@end
