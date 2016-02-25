#import <SSignalKit/SSignalKit.h>

@class TGAudioWaveform;

@interface TGAudioWaveformSignal : NSObject

+ (TGAudioWaveform *)waveformForPath:(NSString *)path;
+ (SSignal *)audioWaveformForFileAtPath:(NSString *)path duration:(NSTimeInterval)duration;

@end
