#import "TGArticleWebpageFooterModel.h"

#import "TGWebPageMediaAttachment.h"

#import "TGModernTextViewModel.h"
#import "TGSignalImageViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGSharedMediaUtils.h"
#import "TGSharedMediaSignals.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedFileSignals.h"

#import "TGReusableLabel.h"

#import "TGMessage.h"

#import "TGImageManager.h"

#import "TGPreparedLocalDocumentMessage.h"
#import "TGTelegraph.h"
#import "TGGifConverter.h"

@interface TGArticleWebpageFooterModel ()
{
    TGWebPageMediaAttachment *_webPage;
    TGModernTextViewModel *_siteModel;
    TGModernTextViewModel *_titleModel;
    TGModernTextViewModel *_textModel;
    TGSignalImageViewModel *_imageViewModel;
    TGModernFlatteningViewModel *_durationModel;
    TGModernImageViewModel *_durationBackgroundModel;
    TGModernTextViewModel *_durationLabelModel;
    TGModernImageViewModel *_serviceIconModel;
    bool _imageInText;
    bool _hasViews;
    
    NSString *_imageDataInvalidationUrl;
    void (^_imageDataInvalidationBlock)();
    
    bool _isAnimation;
    bool _activatedMedia;
}

@end

@implementation TGArticleWebpageFooterModel

static CTFontRef titleFont()
{
    static CTFontRef font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGCoreTextMediumFontOfSize(14.0f);
    });
    
    return font;
}

static CTFontRef textFont()
{
    static CTFontRef font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGCoreTextSystemFontOfSize(14.0f);
    });
    
    return font;
}

static CTFontRef durationFont()
{
    static CTFontRef font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGCoreTextSystemFontOfSize(11.0f);
    });
    
    return font;
}

static UIImage *durationBackgroundImage()
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 2.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.6f).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage imageInText:(bool)imageInText hasViews:(bool)hasViews
{
    self = [super initWithContext:context incoming:incoming];
    if (self != nil)
    {
        _webPage = webPage;
        _hasViews = hasViews;
        
        _imageInText = imageInText;
        if (webPage.pageDescription.length == 0)
            _imageInText = false;
        
        if (webPage.siteName.length != 0)
        {
            _siteModel = [[TGModernTextViewModel alloc] initWithText:webPage.siteName font:titleFont()];
            _siteModel.textColor = [TGWebpageFooterModel colorForAccentText:incoming];
            [self addSubmodel:_siteModel];
        }
        
        NSString *title = webPage.title;
        if (title.length == 0)
            title = webPage.author;
        
        if (title.length != 0)
        {
            _titleModel = [[TGModernTextViewModel alloc] initWithText:title font:titleFont()];
            _titleModel.layoutFlags = TGReusableLabelLayoutMultiline;
            _titleModel.maxNumberOfLines = 4;
            _titleModel.textColor = [UIColor blackColor];
            [self addSubmodel:_titleModel];
        }
        
        if (webPage.pageDescription.length != 0)
        {
            _textModel = [[TGModernTextViewModel alloc] initWithText:webPage.pageDescription font:textFont()];
            _textModel.layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
            _textModel.textCheckingResults = [TGMessage textCheckingResultsForText:webPage.pageDescription highlightMentionsAndTags:false highlightCommands:false];
            _textModel.maxNumberOfLines = 16;
            _textModel.textColor = [UIColor blackColor];
            if (_imageInText)
            {
                _textModel.linesInset = [[TGModernTextViewLinesInset alloc] initWithNumberOfLinesToInset:_titleModel != nil ? 2 : 3 inset:60.0f];
            }
            [self addSubmodel:_textModel];
        }
        
        CGSize imageSize = CGSizeZero;
        
        bool hasSize = false;
        
        if (!imageInText && webPage.document != nil && ([webPage.document.mimeType isEqualToString:@"image/gif"] || [webPage.document.mimeType isEqualToString:@"video/mp4"]) && [webPage.document isAnimated]) {
            
            _isAnimation = true;
            
            for (id attribute in webPage.document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
                    imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
                    hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
                    break;
                } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                    imageSize = ((TGDocumentAttributeVideo *)attribute).size;
                    hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
                    break;
                }
            }
        } else if (!imageInText && webPage.photo != nil) {
            [webPage.photo.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&imageSize];
        } else if (imageInText) {
            [webPage.photo.imageInfo closestImageUrlWithSize:CGSizeMake(50.0f, 50.0f) resultingSize:&imageSize];
        }
        
        if (_isAnimation) {
            _imageDataInvalidationUrl = [webPage.document.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        } else {
            _imageDataInvalidationUrl = [webPage.photo.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        }
        
        if (imageSize.width > FLT_EPSILON)
        {
            CGRect contentFrame = CGRectZero;
            if (imageInText)
                imageSize = CGSizeMake(50.0f, 50.0f);
            else
            {
                if (_isAnimation) {
                    CGSize fitSize = CGSizeMake(220.0f, 220.0f);
                    imageSize = TGFitSize(TGScaleToFill(imageSize, fitSize), fitSize);
                    contentFrame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
                } else {
                    CGFloat imageAspect = imageSize.width / imageSize.height;
                    CGSize fitSize = CGSizeMake(215.0f, 180.0f);
                    if (ABS(imageAspect - 1.0f) < FLT_EPSILON)
                        fitSize = CGSizeMake(215.0f, 215.0f);
                        
                    imageSize = TGScaleToFill(imageSize, fitSize);
                    CGSize completeSize = imageSize;
                    imageSize = TGCropSize(imageSize, fitSize);
                    contentFrame = CGRectMake((imageSize.width - completeSize.width) / 2.0f, (imageSize.height - completeSize.height) / 2.0f, completeSize.width, completeSize.height);
                }
            }
            _imageViewModel = [[TGSignalImageViewModel alloc] init];
            _imageViewModel.viewUserInteractionDisabled = false;
            _imageViewModel.transitionContentRect = contentFrame;
            if (_isAnimation) {
                NSString *key = [[NSString alloc] initWithFormat:@"webpage-animation-thumbnail-%" PRId64 "", webPage.document.documentId];
                __weak TGArticleWebpageFooterModel *weakSelf = self;
                _imageDataInvalidationBlock = ^{
                    __strong TGArticleWebpageFooterModel *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf->_imageViewModel reload];
                    }
                };
                [_imageViewModel setSignalGenerator:^SSignal *{
                    return [TGSharedFileSignals squareFileThumbnail:webPage.document ofSize:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:8.0f]];
                } identifier:key];
            } else {
                if (imageInText) {
                    NSString *key = [[NSString alloc] initWithFormat:@"webpage-image-small-thumbnail-%" PRId64 "", webPage.photo.imageId];
                    __weak TGArticleWebpageFooterModel *weakSelf = self;
                    _imageDataInvalidationBlock = ^{
                        __strong TGArticleWebpageFooterModel *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf->_imageViewModel reload];
                        }
                    };
                    [_imageViewModel setSignalGenerator:^SSignal *
                    {
                        return [TGSharedPhotoSignals sharedPhotoImage:webPage.photo size:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:8.0f] cacheKey:key];
                    } identifier:key];
                } else {
                    NSString *key = [[NSString alloc] initWithFormat:@"webpage-image-thumbnail-%" PRId64 "", webPage.photo.imageId];
                    __weak TGArticleWebpageFooterModel *weakSelf = self;
                    _imageDataInvalidationBlock = ^{
                        __strong TGArticleWebpageFooterModel *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf->_imageViewModel reload];
                        }
                    };
                    [_imageViewModel setSignalGenerator:^SSignal *
                    {
                        return [TGSharedPhotoSignals squarePhotoThumbnail:webPage.photo ofSize:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:8.0f] downloadLargeImage: false placeholder:nil];
                    } identifier:key];
                }
            }
            _imageViewModel.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
            _imageViewModel.skipDrawInContext = true;
            if (imageInText) {
                _imageViewModel.showProgress = false;
            } else {
                [_imageViewModel setManualProgress:true];
                [_imageViewModel setNone];
            }
            
            [self addSubmodel:_imageViewModel];
            
            if (!_imageInText)
            {
                if (imageSize.width >= 30.0f && imageSize.height >= 26.0f)
                {
                    if (webPage.duration != nil)
                    {
                        _durationModel = [[TGModernFlatteningViewModel alloc] init];
                        
                        _durationBackgroundModel = [[TGModernImageViewModel alloc] initWithImage:durationBackgroundImage()];
                        [_durationModel addSubmodel:_durationBackgroundModel];
                        
                        int duration = [webPage.duration intValue];
                        NSString *durationText = @"";
                        if (duration >= 60 * 60)
                            durationText = [[NSString alloc] initWithFormat:@"%d:%02d:%02d", duration / (60 * 60), (duration % (60 * 60)) / 60, duration % 60];
                        else
                            durationText = [[NSString alloc] initWithFormat:@"%d:%02d", duration / 60, duration % 60];
                        
                        _durationLabelModel = [[TGModernTextViewModel alloc] initWithText:durationText font:durationFont()];
                        _durationLabelModel.textColor = [UIColor whiteColor];
                        [_durationLabelModel layoutForContainerSize:CGSizeMake(200.0f, 200.0f)];
                        [_durationModel addSubmodel:_durationLabelModel];
                        
                        [_imageViewModel addSubmodel:_durationModel];
                    }
                    else if ([webPage.pageType isEqualToString:@"video"])
                    {
                        if ([[webPage.siteName lowercaseString] isEqualToString:@"instagram"])
                        {
                            _serviceIconModel = [[TGModernImageViewModel alloc] initWithImage:[UIImage imageNamed:@"InlineMediaInstagramVideoIcon.png"]];
                            [_serviceIconModel sizeToFit];
                            [_imageViewModel addSubmodel:_serviceIconModel];
                        }
                    }
                }
            }
        }
        
        if (_titleModel == nil && _textModel == nil)
        {
            _siteModel.layoutFlags |= TGReusableLabelLayoutDateSpacing | (incoming ? 0 : TGReusableLabelLayoutExtendedDateSpacing);
            if (_hasViews) {
                _siteModel.layoutFlags |= TGReusableLabelViewCountSpacing;
            }
        }
        else if (_textModel == nil && (_imageViewModel == nil && !_imageInText))
        {
            _titleModel.layoutFlags |= TGReusableLabelLayoutDateSpacing | (incoming ? 0 : TGReusableLabelLayoutExtendedDateSpacing);
            if (_hasViews) {
                _titleModel.layoutFlags |= TGReusableLabelViewCountSpacing;
            }
        }
        else if (_imageViewModel == nil || _imageInText)
        {
            _textModel.layoutFlags |= TGReusableLabelLayoutDateSpacing | (incoming ? 0 : TGReusableLabelLayoutExtendedDateSpacing);
            if (_hasViews) {
                _textModel.layoutFlags |= TGReusableLabelViewCountSpacing;
            }
        }
    }
    return self;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _imageViewModel.parentOffset = itemPosition;
    [_imageViewModel bindViewToContainer:container viewStorage:viewStorage];
    
    if (self.context.autoplayAnimations && self.mediaIsAvailable && self.boundToContainer) {
        [self activateWebpageContents];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [super unbindView:viewStorage];
    
    [_imageViewModel setVideoPathSignal:nil];
    _activatedMedia = false;
    [self updateOverlayAnimated:false];
}

- (void)updateSpecialViewsPositions:(CGPoint)itemPosition
{
    _imageViewModel.parentOffset = itemPosition;
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize contentSize:(CGSize)topContentSize needsContentsUpdate:(bool *)needsContentsUpdate
{
    CGSize contentContainerSize = CGSizeMake(MAX(containerSize.width - 10.0f - 20.0f, topContentSize.width - 10.0f - 20.0f), containerSize.height);
    
    CGFloat imageInset = 0.0f;
    if (_imageInText)
    {
        imageInset = _imageViewModel.frame.size.width + 6.0f;
    }
    else if (_imageViewModel.frame.size.width >= 180.0f)
    {
        contentContainerSize.width = _imageViewModel.frame.size.width;
    }
    
    CGSize textContainerSize = CGSizeMake(contentContainerSize.width - imageInset, contentContainerSize.height);
    
    if (_siteModel != nil && [_siteModel layoutNeedsUpdatingForContainerSize:textContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        [_siteModel layoutForContainerSize:textContainerSize];
    }
    
    if ([_titleModel layoutNeedsUpdatingForContainerSize:textContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        [_titleModel layoutForContainerSize:textContainerSize];
    }
    
    CGSize adjustedTextContainerSize = contentContainerSize;
    if (_textModel != nil && [_textModel layoutNeedsUpdatingForContainerSize:adjustedTextContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        NSInteger numberOfLines = 3;
        numberOfLines = MAX(0, numberOfLines - (NSInteger)_titleModel.measuredNumberOfLines);
        if (!_imageInText)
            numberOfLines = 0;
        if (numberOfLines != 0)
            _textModel.linesInset = [[TGModernTextViewLinesInset alloc] initWithNumberOfLinesToInset:numberOfLines inset:60.0f];
        else
            _textModel.linesInset = nil;
        [_textModel layoutForContainerSize:adjustedTextContainerSize];
    }
    
    CGSize contentSize = CGSizeZero;
    
    contentSize.height += 2.0 + 2.0f;
    
    if (_siteModel != nil)
    {
        contentSize.width = MAX(contentSize.width, _siteModel.frame.size.width + 10.0f + imageInset);
        contentSize.height += _siteModel.frame.size.height;
        
        if (_titleModel == nil && _textModel == nil && _imageViewModel == nil) {
            contentSize.height += 14.0f;
        }
    }
    
    if (_titleModel != nil)
    {
        if (_siteModel != nil)
            contentSize.height += 3.0f;
        contentSize.width = MAX(contentSize.width, _titleModel.frame.size.width + 10.0f + imageInset);
        contentSize.height += _titleModel.frame.size.height;
    }
    
    if (_textModel != nil)
    {
        if (_siteModel != nil || _titleModel != nil)
            contentSize.height += 3.0f;
        contentSize.width = MAX(contentSize.width, _textModel.frame.size.width + 10.0f);
        contentSize.height += _textModel.frame.size.height;
    }
    
    if (_imageViewModel != nil)
    {
        if (!_imageInText)
        {
            if (_siteModel != nil || _titleModel != nil || _textModel != nil)
                contentSize.height += 3.0f;
            contentSize.height += 17.0f;
        }
        
        if (_imageInText)
            contentSize.width = MAX(contentSize.width, _imageViewModel.frame.size.width + 10.0f);
        else
            contentSize.width = MAX(contentSize.width, _imageViewModel.frame.size.width + 10.0f);
        
        if (!_imageInText)
            contentSize.height += _imageViewModel.frame.size.height;
        else
            contentSize.height = MAX(contentSize.height, _imageViewModel.frame.size.height + 40.0f);
    }
    
    return contentSize;
}

- (bool)preferWebpageSize
{
    return _imageViewModel.frame.size.width >= 190.0f;
}

- (TGWebpageFooterModelAction)webpageActionAtPoint:(CGPoint)point
{
    bool result = _imageViewModel != nil && CGRectContainsPoint(_imageViewModel.frame, point);
    if (result && _imageInText) {
        return TGWebpageFooterModelActionOpenURL;
    }
    
    if (!result && [self linkAtPoint:point regionData:NULL] == nil && CGRectContainsPoint(self.bounds, point))
    {
        if ([_webPage.pageType isEqualToString:@"audio"])
            return TGWebpageFooterModelActionGeneric;
    }
    
    if (result) {
        if (!_imageInText) {
            if (!self.mediaIsAvailable) {
                return TGWebpageFooterModelActionDownload;
            } else {
                if (_isAnimation) {
                    return TGWebpageFooterModelActionPlay;
                }
            }
        }
        
        return TGWebpageFooterModelActionGeneric;
    }
    
    return TGWebpageFooterModelActionNone;
}

- (NSString *)linkAtPoint:(CGPoint)point regionData:(NSArray *__autoreleasing *)regionData
{
    NSArray *originalRegionData = nil;
    NSMutableArray *offsetRegionData = [[NSMutableArray alloc] init];
    
    NSString *link = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:&originalRegionData];
    
    if (link != nil && originalRegionData != nil)
    {
        for (NSValue *value in originalRegionData)
        {
            [offsetRegionData addObject:[NSValue valueWithCGRect:CGRectOffset([value CGRectValue], _textModel.frame.origin.x, _textModel.frame.origin.y)]];
        }
        
        if (regionData != nil)
            *regionData = offsetRegionData;
    }
    
    return link;
}

- (UIView *)referenceViewForImageTransition
{
    return _imageViewModel.boundView;
}

- (void)setMediaVisible:(bool)mediaVisible
{
    _imageViewModel.hidden = !mediaVisible;
}

- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)bottomInset
{
    CGFloat currentOffset = -4.0f;
    _siteModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _siteModel.frame.size.width, _siteModel.frame.size.height);
    
    if (_imageViewModel != nil && _imageInText)
    {
        _imageViewModel.frame = CGRectMake(rect.origin.x + rect.size.width - _imageViewModel.frame.size.width, rect.origin.y + 20.0f, _imageViewModel.frame.size.width, _imageViewModel.frame.size.height);
    }
    
    if (_siteModel != nil)
        currentOffset += 2.0f + _siteModel.frame.size.height;
    
    _titleModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _titleModel.frame.size.width, _titleModel.frame.size.height);
    
    if (_titleModel != nil)
        currentOffset += 2.0f + _titleModel.frame.size.height;
    
    _textModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _textModel.frame.size.width, _textModel.frame.size.height);
    
    if (_textModel != nil)
        currentOffset += 7.0f + _textModel.frame.size.height;
    else
        currentOffset += 4.0f;
    
    if (!_imageInText)
    {
        _imageViewModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _imageViewModel.frame.size.width, _imageViewModel.frame.size.height);
        if (_imageViewModel != nil)
        {
            if (bottomInset)
                *bottomInset = 11.0f;
        }
    }
    else
    {
        if (_textModel.containsEmptyNewline)
        {
            if (bottomInset)
                *bottomInset = 11.0f;
        }
    }
    
    if (_durationModel != nil)
    {
        _durationBackgroundModel.frame = CGRectMake(0.0f, 0.0f, _durationLabelModel.frame.size.width + 12.0f, 18.0f);
        CGRect durationModelFrame = CGRectMake(_imageViewModel.frame.size.width - _durationBackgroundModel.frame.size.width - 4.0f, _imageViewModel.frame.size.height - _durationBackgroundModel.frame.size.height - 4.0f, _durationBackgroundModel.frame.size.width, _durationBackgroundModel.frame.size.height);
        if (!CGSizeEqualToSize(_durationModel.frame.size, durationModelFrame.size))
            [_durationModel setNeedsSubmodelContentsUpdate];
        _durationModel.frame = durationModelFrame;
        
        _durationLabelModel.frame = CGRectMake(5.0f, 1.0f, _durationLabelModel.frame.size.width, _durationLabelModel.frame.size.height);
        
        [_durationModel updateSubmodelContentsIfNeeded];
    }
    
    if (_serviceIconModel != nil)
    {
        _serviceIconModel.frame = CGRectMake(_imageViewModel.frame.size.width - _serviceIconModel.frame.size.width - 3.0f - TGRetinaPixel, 4.0f, _serviceIconModel.frame.size.width, _serviceIconModel.frame.size.height);
    }
}

- (bool)activateWebpageContents
{
    if (self.mediaIsAvailable && _isAnimation) {
        if (_activatedMedia && !self.context.autoplayAnimations) {
            _activatedMedia = false;
            [_imageViewModel setVideoPathSignal:nil];
            [self updateOverlayAnimated:false];
        } else {
            _activatedMedia = true;
            [self updateOverlayAnimated:false];
            
            TGDocumentMediaAttachment *document = _webPage.document;
            if (document != nil) {
                NSString *documentDirectory = nil;
                if (document.localDocumentId != 0) {
                    documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId];
                } else {
                    documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId];
                }
                
                NSString *videoPath = nil;
                
                if ([document.mimeType isEqualToString:@"video/mp4"]) {
                    if (document.localDocumentId != 0) {
                        videoPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId] stringByAppendingPathComponent:[document safeFileName]];
                    } else {
                        videoPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId] stringByAppendingPathComponent:[document safeFileName]];
                    }
                }
                
                if (videoPath != nil) {
                    [_imageViewModel setVideoPathSignal:[SSignal single:videoPath]];
                } else {
                    NSString *filePath = nil;
                    NSString *videoPath = nil;
                    
                    if (document.localDocumentId != 0)
                    {
                        filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId] stringByAppendingPathComponent:[document safeFileName]];
                        videoPath = [filePath stringByAppendingString:@".mov"];
                    }
                    else
                    {
                        filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId] stringByAppendingPathComponent:[document safeFileName]];
                        videoPath = [filePath stringByAppendingString:@".mov"];
                    }
                    
                    NSString *key = [@"gif-video-path:" stringByAppendingString:filePath];
                    
                    SSignal *videoSignal = [[SSignal defer:^SSignal *{
                        if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL]) {
                            return [SSignal single:videoPath];
                        } else {
                            return [TGTelegraphInstance.genericTasksSignalManager multicastedSignalForKey:key producer:^SSignal *{
                                SSignal *dataSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                                    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
                                    if (data != nil) {
                                        [subscriber putNext:data];
                                        [subscriber putCompletion];
                                    } else {
                                        [subscriber putError:nil];
                                    }
                                    return nil;
                                }];
                                return [dataSignal mapToSignal:^SSignal *(NSData *data) {
                                    return [[TGGifConverter convertGifToMp4:data] mapToSignal:^SSignal *(NSString *tempPath) {
                                        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subsctiber) {
                                            NSError *error = nil;
                                            [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:videoPath error:&error];
                                            if (error != nil) {
                                                [subsctiber putError:nil];
                                            } else {
                                                [subsctiber putNext:videoPath];
                                                [subsctiber putCompletion];
                                            }
                                            return nil;
                                        }];
                                    }];
                                }];
                            }];
                        }
                    }] startOn:[SQueue concurrentDefaultQueue]];
                    
                    [_imageViewModel setVideoPathSignal:videoSignal];
                }
            }
        }
    }
    
    return false;
}

- (bool)webpageContentsActivated
{
    return false;
}

- (void)setMediaIsAvailable:(bool)mediaIsAvailable {
    bool wasAvailable = self.mediaIsAvailable;
    
    [super setMediaIsAvailable:mediaIsAvailable];
    
    if (!wasAvailable && mediaIsAvailable && self.boundToContainer) {
        if ([_imageViewModel boundView] != nil && self.context.autoplayAnimations && mediaIsAvailable) {
            [self activateWebpageContents];
        }
    }
    
    [self updateOverlayAnimated:false];
}

- (void)updateMediaProgressVisible:(bool)mediaProgressVisible mediaProgress:(float)mediaProgress animated:(bool)animated {
    [super updateMediaProgressVisible:mediaProgressVisible mediaProgress:mediaProgress animated:animated];
    
    [self updateOverlayAnimated:animated];
}

- (void)imageDataInvalidated:(NSString *)imageUrl {
    if ([_imageDataInvalidationUrl isEqualToString:imageUrl]) {
        if (_imageDataInvalidationBlock) {
            _imageDataInvalidationBlock();
        }
    }
}

- (void)stopInlineMedia
{
    [_imageViewModel setVideoPathSignal:nil];
    _activatedMedia = false;
    if (_isAnimation) {
        [self updateOverlayAnimated:false];
    }
}

- (void)updateOverlayAnimated:(bool)animated {
    if (_imageViewModel.manualProgress) {
        if (self.mediaProgressVisible) {
            [_imageViewModel setProgress:self.mediaProgress animated:animated];
        } else if (self.mediaIsAvailable) {
            if (_activatedMedia) {
                [_imageViewModel setNone];
            } else {
                if (self.context.autoplayAnimations) {
                    [_imageViewModel setNone];
                } else if (_isAnimation) {
                    [_imageViewModel setPlay];
                } else {
                    [_imageViewModel setNone];
                }
            }
        } else {
            [_imageViewModel setDownload];
        }
    }
}

- (void)resumeInlineMedia {
    if (_isAnimation && self.context.autoplayAnimations && self.mediaIsAvailable && !_activatedMedia) {
        [self activateWebpageContents];
    }
}

@end
