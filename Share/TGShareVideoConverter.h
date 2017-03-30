#import <SSignalKit/SSignalKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TGShareVideoConverter : NSObject

+ (SSignal *)convertAVAsset:(AVAsset *)avAsset;

@end
