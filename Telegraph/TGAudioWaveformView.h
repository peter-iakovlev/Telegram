#import <Foundation/Foundation.h>

@class TGAudioWaveform;

@interface TGAudioWaveformView : UIView

@property (nonatomic) CGFloat peakHeight;

- (void)setForegroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor;
- (void)setWaveform:(TGAudioWaveform *)waveform;

- (UIView *)backgroundView;
- (UIView *)foregroundView;
- (UIView *)foregroundClippingView;

@end
