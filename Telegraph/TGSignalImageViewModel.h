#import "TGModernViewModel.h"

#import <SSignalKit/SSignalKit.h>

@interface TGSignalImageViewModel : TGModernViewModel

@property (nonatomic) bool showProgress;
@property (nonatomic) bool manualProgress;

@property (nonatomic) UIEdgeInsets inlineVideoInsets;
@property (nonatomic) CGSize inlineVideoSize;
@property (nonatomic) CGFloat inlineVideoCornerRadius;

@property (nonatomic) CGRect transitionContentRect;

- (void)setSignalGenerator:(SSignal *(^)())signalGenerator identifier:(NSString *)identifier;

- (void)setProgress:(float)progress animated:(bool)animated;
- (void)setDownload;
- (void)setNone;
- (void)setPlay;

- (void)reload;

- (void)setVideoPathSignal:(SSignal *)videoPathSignal;

@end
