#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@class TGPhotoEditorPreviewView;
@protocol TGMediaEditAdjustments;

@interface PGPhotoEditor : NSObject

@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, readonly) CGSize rotatedCropSize;
@property (nonatomic, assign) CGFloat cropRotation;
@property (nonatomic, assign) CGFloat cropLockedAspectRatio;
@property (nonatomic, assign) UIImageOrientation cropOrientation;

@property (nonatomic, weak) TGPhotoEditorPreviewView *previewOutput;
@property (nonatomic, readonly) NSArray *tools;

@property (nonatomic, readonly) bool processing;
@property (nonatomic, readonly) bool readyForProcessing;

- (instancetype)initWithOriginalSize:(CGSize)originalSize adjustments:(id<TGMediaEditAdjustments>)adjustments forVideo:(bool)forVideo;

- (void)setImage:(UIImage *)image forCropRect:(CGRect)cropRect cropRotation:(CGFloat)cropRotation cropOrientation:(UIImageOrientation)cropOrientation;

- (void)processAnimated:(bool)animated completion:(void (^)(void))completion;

- (void)createResultImageWithCompletion:(void (^)(UIImage *image))completion;

- (bool)needsImageRecropping;
- (bool)hasDefaultCropping;

- (SSignal *)histogramSignal;

- (id<TGMediaEditAdjustments>)exportAdjustments;

@end
