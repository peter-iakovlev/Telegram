#import "PGPhotoEditor.h"

#import "ATQueue.h"
#import "TGMemoryImageCache.h"

#import "TGPhotoEditorUtils.h"
#import "TGPhotoEditorPreviewView.h"
#import "PGPhotoEditorView.h"
#import "PGPhotoEditorPicture.h"

#import "PGPhotoEditorValues.h"
#import "TGVideoEditAdjustments.h"

#import "PGPhotoToolComposer.h"
#import "PGEnhanceTool.h"
#import "PGExposureTool.h"
#import "PGContrastTool.h"
#import "PGWarmthTool.h"
#import "PGSaturationTool.h"
#import "PGHighlightsTool.h"
#import "PGShadowsTool.h"
#import "PGVignetteTool.h"
#import "PGGrainTool.h"
#import "PGBlurTool.h"
#import "PGSharpenTool.h"
#import "PGFadeTool.h"
#import "PGTintTool.h"
#import "PGCurvesTool.h"

#import "PGPhotoHistogramGenerator.h"

@interface PGPhotoEditor ()
{
    PGPhotoToolComposer *_toolComposer;
    
    id<TGMediaEditAdjustments> _initialAdjustments;
    
    PGPhotoEditorPicture *_currentInput;
    NSArray *_currentProcessChain;
    GPUImageOutput <GPUImageInput> *_finalFilter;
    
    PGPhotoHistogram *_currentHistogram;
    PGPhotoHistogramGenerator *_histogramGenerator;
    
    UIImageOrientation _imageCropOrientation;
    CGRect _imageCropRect;
    CGFloat _imageCropRotation;
    
    SPipe *_histogramPipe;
    
    ATQueue *_queue;
    
    bool _forVideo;
    
    bool _processing;
    bool _needsReprocessing;
}
@end

@implementation PGPhotoEditor

- (instancetype)initWithOriginalSize:(CGSize)originalSize adjustments:(id<TGMediaEditAdjustments>)adjustments forVideo:(bool)forVideo
{
    self = [super init];
    if (self != nil)
    {
        _forVideo = forVideo;
        
        _queue = [[ATQueue alloc] init];
        
        _originalSize = originalSize;
        _cropRect = CGRectMake(0.0f, 0.0f, _originalSize.width, _originalSize.height);
        
        _tools = [self toolsInit];
        
        _toolComposer = [[PGPhotoToolComposer alloc] init];
        [_toolComposer addPhotoTools:_tools];
        [_toolComposer compose];

        _histogramPipe = [[SPipe alloc] init];
        
        __weak PGPhotoEditor *weakSelf = self;
        _histogramGenerator = [[PGPhotoHistogramGenerator alloc] init];
        _histogramGenerator.histogramReady = ^(PGPhotoHistogram *histogram)
        {
            __strong PGPhotoEditor *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;

            strongSelf->_currentHistogram = histogram;
            strongSelf->_histogramPipe.sink(histogram);
        };
        
        [self _importAdjustments:adjustments];
    }
    return self;
}

- (NSArray *)toolsInit
{
    NSMutableArray *tools = [NSMutableArray array];
    for (Class toolClass in [PGPhotoEditor availableTools])
    {
        PGPhotoTool *toolInstance = [[toolClass alloc] init];
        [tools addObject:toolInstance];
    }
    
    return tools;
}

- (void)setImage:(UIImage *)image forCropRect:(CGRect)cropRect cropRotation:(CGFloat)cropRotation cropOrientation:(UIImageOrientation)cropOrientation
{
    [_toolComposer invalidate];
    _currentProcessChain = nil;
    
    _imageCropRect = cropRect;
    _imageCropRotation = cropRotation;
    _imageCropOrientation = cropOrientation;
    
    [_currentInput removeAllTargets];
    _currentInput = [[PGPhotoEditorPicture alloc] initWithImage:image];
    
    _histogramGenerator.imageSize = image.size;
}

#pragma mark - Properties

- (CGSize)rotatedCropSize
{
    if (_cropOrientation == UIImageOrientationLeft || _cropOrientation == UIImageOrientationRight)
        return CGSizeMake(_cropRect.size.height, _cropRect.size.width);
    
    return _cropRect.size;
}

- (bool)needsImageRecropping
{
    if (!_CGRectEqualToRectWithEpsilon(self.cropRect, _imageCropRect, FLT_EPSILON) || self.cropOrientation != _imageCropOrientation || ABS(self.cropRotation - _imageCropRotation) > FLT_EPSILON)
    {
        return true;
    }
    
    return false;
}

- (bool)hasDefaultCropping
{
    if (!_CGRectEqualToRectWithEpsilon(self.cropRect, CGRectMake(0, 0, _originalSize.width, _originalSize.height), 1.0f) || self.cropOrientation != UIImageOrientationUp || ABS(self.cropRotation) > FLT_EPSILON)
    {
        return false;
    }
    
    return true;
}

#pragma mark - Processing

- (bool)readyForProcessing
{
    return (_currentInput != nil);
}

- (void)processAnimated:(bool)animated completion:(void (^)(void))completion
{
    [self processAnimated:animated capture:false completion:completion];
}

- (void)processAnimated:(bool)animated capture:(bool)capture completion:(void (^)(void))completion
{
    if (self.previewOutput == nil)
        return;
    
    if (iosMajorVersion() < 7)
        animated = false;
    
    if (_processing && completion == nil)
    {
        _needsReprocessing = true;
        return;
    }
    
    _processing = true;
    
    [_queue dispatch:^
    {
        NSMutableArray *processChain = [NSMutableArray array];
        
        for (PGPhotoTool *tool in _toolComposer.advancedTools)
        {
            if (!tool.shouldBeSkipped && tool.pass != nil)
                [processChain addObject:tool.pass];
        }
        
        _toolComposer.imageSize = _cropRect.size;
        [processChain addObject:_toolComposer];
        
        TGPhotoEditorPreviewView *previewOutput = self.previewOutput;
        
        if (![_currentProcessChain isEqualToArray:processChain])
        {
            [_currentInput removeAllTargets];
            
            for (PGPhotoProcessPass *pass in _currentProcessChain)
                [pass.filter removeAllTargets];
            
            _currentProcessChain = processChain;
            
            GPUImageOutput <GPUImageInput> *lastFilter = ((PGPhotoProcessPass *)_currentProcessChain.firstObject).filter;
            [_currentInput addTarget:lastFilter];
            
            NSInteger chainLength = _currentProcessChain.count;
            if (chainLength > 1)
            {
                for (NSInteger i = 1; i < chainLength; i++)
                {
                    PGPhotoProcessPass *pass = ((PGPhotoProcessPass *)_currentProcessChain[i]);
                    GPUImageOutput <GPUImageInput> *filter = pass.filter;
                    [lastFilter addTarget:filter];
                    lastFilter = filter;
                }
            }
            _finalFilter = lastFilter;
            
            [_finalFilter addTarget:previewOutput.imageView];
            [_finalFilter addTarget:_histogramGenerator];            
        }
        
        if (capture)
            [_finalFilter useNextFrameForImageCapture];
        
        for (PGPhotoProcessPass *pass in _currentProcessChain)
            [pass process];
        
        if (animated)
        {
            TGDispatchOnMainThread(^
            {
                [previewOutput prepareTransitionFadeView];
            });
        }
        
        [_currentInput processSynchronous:true completion:^
        {            
            if (completion != nil)
                completion();
            
            _processing = false;
             
            if (animated)
            {
                TGDispatchOnMainThread(^
                {
                    [previewOutput performTransitionFade];
                });
            }
            
            if (_needsReprocessing)
            {
                _needsReprocessing = false;
                [self processAnimated:false completion:nil];
            }
        }];
    }];
}

#pragma mark - Result

- (void)createResultImageWithCompletion:(void (^)(UIImage *image))completion
{
    [self processAnimated:false capture:true completion:^
    {
        UIImage *image = [_finalFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
        
        //NSData *data = UIImagePNGRepresentation(image);
        //[data writeToFile:@"/Users/ilyalaktyushin/Desktop/noise.png" atomically:true];
        
        if (completion != nil)
            completion(image);
    }];
}

#pragma mark - Editor Values

- (void)_importAdjustments:(id<TGMediaEditAdjustments>)adjustments
{
    _initialAdjustments = adjustments;
    
    if (adjustments != nil)
        self.cropRect = adjustments.cropRect;
    
    self.cropOrientation = adjustments.cropOrientation;
    self.cropLockedAspectRatio = adjustments.cropLockedAspectRatio;
    
    PGPhotoEditorValues *editorValues = nil;
    if ([adjustments isKindOfClass:[PGPhotoEditorValues class]])
        editorValues = (PGPhotoEditorValues *)adjustments;

    self.cropRotation = editorValues.cropRotation;

    for (PGPhotoTool *tool in self.tools)
    {
        id value = editorValues.toolValues[tool.identifier];
        if (value != nil && [value isKindOfClass:[tool valueClass]])
            tool.value = [value copy];
    }
}

- (id<TGMediaEditAdjustments>)exportAdjustments
{
    if (!_forVideo)
    {
        NSMutableDictionary *toolValues = [[NSMutableDictionary alloc] init];
        for (PGPhotoTool *tool in self.tools)
        {
            if (!tool.shouldBeSkipped)
            {
                if (!([tool.value isKindOfClass:[NSNumber class]] && ABS([tool.value floatValue] - (float)tool.defaultValue) < FLT_EPSILON))
                    toolValues[tool.identifier] = [tool.value copy];
            }
        }
        
        return [PGPhotoEditorValues editorValuesWithOriginalSize:self.originalSize cropRect:self.cropRect cropRotation:self.cropRotation cropOrientation:self.cropOrientation cropLockedAspectRatio:self.cropLockedAspectRatio toolValues:toolValues];
    }
    else
    {
        TGVideoEditAdjustments *initialAdjustments = (TGVideoEditAdjustments *)_initialAdjustments;
        
        return [TGVideoEditAdjustments editAdjustmentsWithOriginalSize:self.originalSize cropRect:self.cropRect cropOrientation:self.cropOrientation cropLockedAspectRatio:self.cropLockedAspectRatio trimStartValue:initialAdjustments.trimStartValue trimEndValue:initialAdjustments.trimEndValue];
    }
}

- (SSignal *)histogramSignal
{
    return [[SSignal single:_currentHistogram] then:_histogramPipe.signalProducer()];
}

+ (NSArray *)availableTools
{
    static NSArray *tools;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        tools = @[ [PGEnhanceTool class],
                   [PGExposureTool class],
                   [PGContrastTool class],
                   [PGWarmthTool class],
                   [PGSaturationTool class],
                   [PGTintTool class],
                   [PGFadeTool class],
                   [PGHighlightsTool class],
                   [PGShadowsTool class],
                   [PGVignetteTool class],
                   [PGGrainTool class],
                   [PGBlurTool class],
                   [PGSharpenTool class],
                   [PGCurvesTool class] ];
    });
    
    return tools;
}

@end
