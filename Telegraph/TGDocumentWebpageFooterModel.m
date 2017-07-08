#import "TGDocumentWebpageFooterModel.h"

#import "TGWebPageMediaAttachment.h"

#import "TGModernLabelViewModel.h"
#import "TGDocumentMessageIconModel.h"
#import "TGMessageImageViewModel.h"
#import "TGAppDelegate.h"
#import "TGFont.h"
#import "TGStringUtils.h"
#import "TGMessageImageView.h"
#import "TGDocumentMessageIconView.h"
#import "TGImageUtils.h"

@interface TGDocumentWebpageFooterModel () <TGMessageImageViewDelegate> {
    TGWebPageMediaAttachment *_webPage;
    bool _hasViews;
    bool _incoming;
    
    NSString *_legacyThumbnailCacheUri;
    
    TGModernLabelViewModel *_documentNameModel;
    TGModernLabelViewModel *_documentSizeModel;
    TGMessageImageViewModel *_imageModel;
    TGDocumentMessageIconModel *_iconModel;
    
    NSString *_titleText;
    NSString *_sizeText;
}

@end

@implementation TGDocumentWebpageFooterModel

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage hasViews:(bool)hasViews
{
    self = [super initWithContext:context incoming:incoming webpage:webPage];
    if (self != nil)
    {
        _webPage = webPage;
        _hasViews = hasViews;
        _incoming = incoming;
        
        TGDocumentMediaAttachment *document = webPage.document;
        if (document != nil) {
            CGSize dimensions = CGSizeZero;
            _legacyThumbnailCacheUri = [document.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
            dimensions.width *= 10.0f;
            dimensions.height *= 10.0f;
            
            NSString *filePreviewUri = nil;
            
            if ((document.documentId != 0 || document.localDocumentId != 0) && _legacyThumbnailCacheUri.length != 0)
            {
                NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
                if (document.documentId != 0)
                    [previewUri appendFormat:@"id=%" PRId64 "", document.documentId];
                else
                    [previewUri appendFormat:@"local-id=%" PRId64 "", document.localDocumentId];
                
                [previewUri appendFormat:@"&file-name=%@", [document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                CGSize thumbnailSize = CGSizeMake(86.0f, 86.0f);
                CGSize renderSize = CGSizeZero;
                if (dimensions.width < dimensions.height)
                {
                    renderSize.height = CGFloor((dimensions.height * thumbnailSize.width / dimensions.width));
                    renderSize.width = thumbnailSize.width;
                }
                else
                {
                    renderSize.width = CGFloor((dimensions.width * thumbnailSize.height / dimensions.height));
                    renderSize.height = thumbnailSize.height;
                }
                
                [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
                
                [previewUri appendString:@"&rounded=1"];
                
                if (_legacyThumbnailCacheUri != nil)
                    [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:_legacyThumbnailCacheUri]];
                
                filePreviewUri = previewUri;
            }
            
            static UIColor *incomingNameColor = nil;
            static UIColor *outgoingNameColor = nil;
            static UIColor *incomingSizeColor = nil;
            static UIColor *outgoingSizeColor = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                incomingNameColor = UIColorRGB(0x0b8bed);
                outgoingNameColor = UIColorRGB(0x3faa3c);
                incomingSizeColor = UIColorRGB(0x999999);
                outgoingSizeColor = UIColorRGB(0x6fb26a);
            });
            
            _titleText = document.fileName;
            
            _documentNameModel = [[TGModernLabelViewModel alloc] initWithText:@"" textColor:incoming ? incomingNameColor : outgoingNameColor font:TGCoreTextSystemFontOfSize(16.0f) maxWidth:145.0f truncateInTheMiddle:true];
            [self addSubmodel:_documentNameModel];
            
            NSString *sizeString = @"";
            if (document.size == INT_MAX)
            {
                sizeString = TGLocalized(@"Conversation.Processing");
            }
            else if (document.size >= 1024 * 1024)
            {
                sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Megabytes"), (float)(float)document.size / (1024 * 1024)];
            }
            else if (document.size >= 1024)
            {
                sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Kilobytes"), (int)(int)(document.size / 1024)];
            }
            else
            {
                sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Bytes"), (int)(int)(document.size)];
            }
            
            _sizeText = sizeString;
            
            _documentSizeModel = [[TGModernLabelViewModel alloc] initWithText:@"" textColor:!incoming ? outgoingSizeColor : incomingSizeColor font:TGCoreTextSystemFontOfSize(13.0f) maxWidth:145.0f];
            [self addSubmodel:_documentSizeModel];
            
            if (filePreviewUri.length != 0)
            {
                _imageModel = [[TGMessageImageViewModel alloc] initWithUri:filePreviewUri];
                _imageModel.skipDrawInContext = true;
                _imageModel.timestampHidden = true;
                _imageModel.overlayDiameter = 44.0f;
                _imageModel.frame = CGRectMake(0.0f, 0.0f, 74.0f, 74.0f);
                [self addSubmodel:_imageModel];
            }
            else
            {
                _iconModel = [[TGDocumentMessageIconModel alloc] init];
                _iconModel.skipDrawInContext = true;
                _iconModel.frame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
                _iconModel.fileName = document.fileName;
                _iconModel.incoming = incoming;
                [self addSubmodel:_iconModel];
            }
        }
    }
    return self;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _imageModel.parentOffset = itemPosition;
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
    (((TGMessageImageViewContainer *)[_imageModel boundView])).imageView.delegate = self;
    
    _iconModel.parentOffset = itemPosition;
    [_iconModel bindViewToContainer:container viewStorage:viewStorage];
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    (((TGMessageImageViewContainer *)[_imageModel boundView])).imageView.delegate = self;
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [super unbindView:viewStorage];
    
    UIView *imageView = [_imageModel boundView];
    ((TGMessageImageViewContainer *)imageView).imageView.delegate = nil;
    
    UIView *iconView = [_iconModel boundView];
    ((TGDocumentMessageIconView *)iconView).delegate = nil;
}

- (void)updateSpecialViewsPositions:(CGPoint)itemPosition
{
    _imageModel.parentOffset = itemPosition;
    _iconModel.parentOffset = itemPosition;
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize contentSize:(CGSize)topContentSize infoWidth:(CGFloat)__unused infoWidth needsContentsUpdate:(bool *)needsContentsUpdate
{
    CGSize contentContainerSize = CGSizeMake(MAX(containerSize.width - 10.0f - 20.0f, topContentSize.width - 10.0f - 20.0f), containerSize.height);
    
    CGSize previewSize = CGSizeZero;
    if (_imageModel != nil)
    {
        previewSize = _imageModel.frame.size;
        previewSize.width -= 2.0f;
        previewSize.height -= 2.0f;
    }
    else
    {
        previewSize = _iconModel.frame.size;
        previewSize.width -= 4.0f + 8.0f;
        previewSize.height -= 4.0f + 8.0f;
    }
    
    [_documentNameModel setText:_titleText maxWidth:contentContainerSize.width - previewSize.width - 16.0f needsContentUpdate:needsContentsUpdate];
    [_documentSizeModel setText:_sizeText maxWidth:contentContainerSize.width - previewSize.width - 16.0f needsContentUpdate:needsContentsUpdate];
    
    CGFloat nameWidth = _documentNameModel.frame.size.width;
    CGFloat sizeWidth = _documentSizeModel.frame.size.width;
    
    return CGSizeMake(MAX(nameWidth, sizeWidth) + previewSize.width + 24.0f, previewSize.height + 11.0f);
}

- (bool)preferWebpageSize
{
    return false;
}

- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)__unused bottomInset
{
    rect.origin.y -= 9.0f;
    
    CGSize previewSize = CGSizeZero;
    if (_imageModel != nil)
        previewSize = _imageModel.frame.size;
    else
    {
        previewSize = CGSizeMake(60.0f, 60.0f);
        previewSize.width -= 4.0f;
        previewSize.height -= 4.0f;
    }
    
    if (_imageModel != nil)
    {
        _documentNameModel.frame = CGRectMake(rect.origin.x + previewSize.width + 14.0f + 8.0f, rect.origin.y + 22.0f, _documentNameModel.frame.size.width, _documentNameModel.frame.size.height);
        _documentSizeModel.frame = CGRectMake(rect.origin.x + previewSize.width + 14.0f + 8.0f, rect.origin.y + 45.0f, _documentSizeModel.frame.size.width, _documentSizeModel.frame.size.height);
    }
    else
    {
        _documentNameModel.frame = CGRectMake(rect.origin.x + previewSize.width + 1.0f + 8.0f, rect.origin.y + 10.0f - TGRetinaPixel, _documentNameModel.frame.size.width, _documentNameModel.frame.size.height);
        _documentSizeModel.frame = CGRectMake(rect.origin.x + previewSize.width + 1.0f + 8.0f, rect.origin.y + 32.0f - TGRetinaPixel, _documentSizeModel.frame.size.width, _documentSizeModel.frame.size.height);
    }
    
    _imageModel.frame = CGRectMake(rect.origin.x + 7.0f - 0.0f, rect.origin.y + 9.0f, _imageModel.frame.size.width, _imageModel.frame.size.height);
    _iconModel.frame = CGRectMake(rect.origin.x + 7.0f - 0.0f, rect.origin.y + 4.0f, _iconModel.frame.size.width, _iconModel.frame.size.height);
}

- (bool)webpageContentsActivated
{
    return false;
}

- (void)setMediaIsAvailable:(bool)mediaIsAvailable {
    //bool wasAvailable = self.mediaIsAvailable;
    
    [super setMediaIsAvailable:mediaIsAvailable];
    
    [self updateImageOverlay:false];
}

- (void)updateMediaProgressVisible:(bool)mediaProgressVisible mediaProgress:(float)mediaProgress animated:(bool)animated {
    bool progressWasVisible = self.mediaProgressVisible;
    float previousProgress = self.mediaProgress;
    
    [super updateMediaProgressVisible:mediaProgressVisible mediaProgress:mediaProgress animated:animated];
    
    [self updateImageOverlay:((progressWasVisible && !self.mediaProgressVisible) || (self.mediaProgressVisible && ABS(self.mediaProgress - previousProgress) > FLT_EPSILON)) && animated];
}

- (void)updateImageOverlay:(bool)animated
{
    _imageModel.viewUserInteractionDisabled = (_incoming && self.mediaIsAvailable) || !self.mediaProgressVisible;
    _iconModel.viewUserInteractionDisabled = (_incoming && self.mediaIsAvailable) || !self.mediaProgressVisible;
    
    if (self.mediaProgressVisible)
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_imageModel setProgress:self.mediaProgress animated:animated];
        
        [_iconModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_iconModel setProgress:self.mediaProgress animated:animated];
    }
    else if (!self.mediaIsAvailable)
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        [_imageModel setProgress:0.0f animated:false];
        
        [_iconModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        [_iconModel setProgress:0.0f animated:false];
    }
    else
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayNone animated:animated];
        
        [_iconModel setOverlayType:TGMessageImageViewOverlayPlay animated:animated];
    }
}

- (void)imageDataInvalidated:(NSString *)imageUrl
{
    if ([_legacyThumbnailCacheUri isEqualToString:imageUrl])
    {
        [_imageModel reloadImage:false];
    }
}

- (TGWebpageFooterModelAction)webpageActionAtPoint:(CGPoint)__unused point
{
    if (!self.mediaIsAvailable) {
        if (self.mediaProgressVisible) {
            return TGWebpageFooterModelActionCancel;
        } else {
            return TGWebpageFooterModelActionDownload;
        }
    }
    return TGWebpageFooterModelActionOpenMedia;
}

@end
