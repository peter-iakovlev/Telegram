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

#import "TGReusableLabel.h"

#import "TGMessage.h"

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

- (instancetype)initWithWithIncoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage imageInText:(bool)imageInText hasViews:(bool)hasViews
{
    self = [super initWithWithIncoming:incoming];
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
            _textModel.maxNumberOfLines = 20;
            _textModel.textColor = [UIColor blackColor];
            if (_imageInText)
            {
                _textModel.linesInset = [[TGModernTextViewLinesInset alloc] initWithNumberOfLinesToInset:_titleModel != nil ? 2 : 3 inset:60.0f];
            }
            [self addSubmodel:_textModel];
        }
        
        CGSize imageSize = CGSizeZero;
        [webPage.photo.imageInfo imageUrlForLargestSize:&imageSize];
        
        if (imageSize.width > FLT_EPSILON)
        {
            CGRect contentFrame = CGRectZero;
            if (imageInText)
                imageSize = CGSizeMake(50.0f, 50.0f);
            else
            {
                CGFloat imageAspect = imageSize.width / imageSize.height;
                CGSize fitSize = CGSizeMake(215.0f, 180.0f);
                if (ABS(imageAspect - 1.0f) < FLT_EPSILON)
                    fitSize = CGSizeMake(215.0f, 215.0f);
                    
                imageSize = TGScaleToFill(imageSize, fitSize);
                CGSize completeSize = imageSize;
                imageSize = TGCropSize(imageSize, fitSize);
                
                contentFrame = CGRectMake((imageSize.width - completeSize.width) / 2.0f, (imageSize.height - completeSize.height) / 2.0f, completeSize.width, completeSize.height);
            }
            _imageViewModel = [[TGSignalImageViewModel alloc] init];
            _imageViewModel.viewUserInteractionDisabled = false;
            _imageViewModel.transitionContentRect = contentFrame;
            NSString *key = [[NSString alloc] initWithFormat:@"webpage-image-%" PRId64 "", webPage.photo.imageId];
            [_imageViewModel setSignalGenerator:^SSignal *
            {
                return [TGSharedPhotoSignals sharedPhotoImage:webPage.photo size:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:8.0f] cacheKey:key];
            } identifier:key];
            _imageViewModel.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
            _imageViewModel.skipDrawInContext = true;
            _imageViewModel.showProgress = !_imageInText;
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

- (bool)hasWebpageActionAtPoint:(CGPoint)point
{
    bool result = _imageViewModel != nil && CGRectContainsPoint(_imageViewModel.frame, point);
    
    if (!result && [self linkAtPoint:point regionData:NULL] == nil && CGRectContainsPoint(self.bounds, point))
    {
        if ([_webPage.pageType isEqualToString:@"audio"])
            return true;
    }
    return result;
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
    return false;
}

- (bool)webpageContentsActivated
{
    return false;
}

@end
