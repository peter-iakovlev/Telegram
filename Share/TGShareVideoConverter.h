#import <SSignalKit/SSignalKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TGShareVideoConverter : NSObject

+ (SSignal *)convertSignalForAVAsset:(AVAsset *)avAsset;

@end
