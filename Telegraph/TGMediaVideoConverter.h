#import <SSignalKit/SSignalKit.h>
#import <AVFoundation/AVFoundation.h>

#import "TGVideoEditAdjustments.h"

typedef enum
{
    TGMediaVideoConversionPresetPassthrough,
    TGMediaVideoConversionPresetCompressed,
    TGMediaVideoConversionPresetAnimation
} TGMediaVideoConversionPreset;

@interface TGMediaVideoConversionResult : NSObject

@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) UIImage *coverImage;

@end

@interface TGMediaVideoConverter : NSObject

+ (SSignal *)convertSignalForAVAsset:(AVAsset *)avAsset preset:(TGMediaVideoConversionPreset)preset adjustments:(TGMediaVideoEditAdjustments *)adjustments;
+ (SSignal *)hashSignalForAVAsset:(AVAsset *)avAsset adjustments:(TGMediaVideoEditAdjustments *)adjustments;

@end
