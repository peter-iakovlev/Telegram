#import <SSignalKit/SSignalKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum
{
    TGMediaVideoConversionPresetCompressedDefault,
    TGMediaVideoConversionPresetCompressedVeryLow,
    TGMediaVideoConversionPresetCompressedLow,
    TGMediaVideoConversionPresetCompressedMedium,
    TGMediaVideoConversionPresetCompressedHigh,
    TGMediaVideoConversionPresetCompressedVeryHigh,
    TGMediaVideoConversionPresetAnimation,
    TGMediaVideoConversionPresetVideoMessage
} TGMediaVideoConversionPreset;

@interface TGShareVideoConverter : NSObject

+ (SSignal *)convertAVAsset:(AVAsset *)avAsset preset:(TGMediaVideoConversionPreset)preset;

@end
