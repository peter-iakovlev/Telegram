#import "TGDocumentMessageViewModel.h"

#import "TGMessage.h"

#import "TGModernRemoteImageViewModel.h"
#import "TGMessageImageViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernLabelViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernClockProgressViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGTextMessageBackgroundViewModel.h"

#import "TGMessageImageViewModel.h"
#import "TGMessageImageView.h"
#import "TGDocumentMessageIconModel.h"
#import "TGDocumentMessageIconView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGDoubleTapGestureRecognizer.h"

@interface TGDocumentMessageViewModel () <TGMessageImageViewDelegate>
{
    NSString *_legacyThumbnailCacheUri;
    bool _mediaIsAvailable;
    bool _progressVisible;
    float _progress;
    
    TGModernLabelViewModel *_documentNameModel;
    TGModernLabelViewModel *_documentSizeModel;
    TGMessageImageViewModel *_imageModel;
    TGDocumentMessageIconModel *_iconModel;
}

@end

@implementation TGDocumentMessageViewModel

- (NSString *)filePathForDocumentId:(int64_t)documentId local:(bool)local
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0];
        filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"file"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filesDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:filesDirectory withIntermediateDirectories:true attributes:nil error:nil];
    });
    
    return [filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", documentId]];
}

- (instancetype)initWithMessage:(TGMessage *)message document:(TGDocumentMediaAttachment *)document author:(TGUser *)author context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message author:author context:context];
    if (self != nil)
    {
        CGSize imageSize = CGSizeMake(86.0f, 86.0f);
        
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
                renderSize.height = floorf((dimensions.height * thumbnailSize.width / dimensions.width));
                renderSize.width = thumbnailSize.width;
            }
            else
            {
                renderSize.width = floorf((dimensions.width * thumbnailSize.height / dimensions.height));
                renderSize.height = thumbnailSize.height;
            }
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            if (_legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", _legacyThumbnailCacheUri];
            
            filePreviewUri = previewUri;
        }
        
        static UIColor *incomingNameColor = nil;
        static UIColor *outgoingNameColor = nil;
        static UIColor *incomingSizeColor = nil;
        static UIColor *outgoingSizeColor = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingNameColor = TGAccentColor();
            outgoingNameColor = UIColorRGB(0x279d28);
            incomingSizeColor = UIColorRGBA(0x525252, 0.6f);
            outgoingSizeColor = UIColorRGB(0x6fb26a);
        });
        
        _documentNameModel = [[TGModernLabelViewModel alloc] initWithText:document.fileName textColor:_incoming ? incomingNameColor : outgoingNameColor font:TGCoreTextSystemFontOfSize(16.0f) maxWidth:135.0f];
        [_contentModel addSubmodel:_documentNameModel];
        
        NSString *sizeString = @"";
        if (document.size < 1024 * 1024)
        {
            sizeString = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.Kilobytes"), (int)(int)(document.size / 1024)];
        }
        else
        {
            sizeString = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.Megabytes"), (float)(float)document.size / (1024 * 1024)];
        }
        
        _documentSizeModel = [[TGModernLabelViewModel alloc] initWithText:sizeString textColor:message.outgoing ? outgoingSizeColor : incomingSizeColor font:TGCoreTextSystemFontOfSize(13.0f) maxWidth:135.0f];
        [_contentModel addSubmodel:_documentSizeModel];
        
        if (filePreviewUri.length != 0)
        {
            _imageModel = [[TGMessageImageViewModel alloc] initWithUri:filePreviewUri];
            _imageModel.skipDrawInContext = true;
            _imageModel.timestampHidden = true;
            _imageModel.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
            [self addSubmodel:_imageModel];
        }
        else
        {
            _iconModel = [[TGDocumentMessageIconModel alloc] init];
            _iconModel.skipDrawInContext = true;
            _iconModel.frame = CGRectMake(0.0f, 0.0f, 80.0f, 90.0f);
            _iconModel.fileExtension = [[document.fileName pathExtension] lowercaseString];
            [self addSubmodel:_iconModel];
        }
    }
    return self;
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage
{   
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage];
    
    _mediaIsAvailable = mediaIsAvailable;
    
    [self updateImageOverlay:false];
}

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated
{
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
    bool progressWasVisible = _progressVisible;
    float previousProgress = _progress;
    
    _progress = progress;
    _progressVisible = progressVisible;
    
    [self updateImageOverlay:((progressWasVisible && !_progressVisible) || (_progressVisible && ABS(_progress - previousProgress) > FLT_EPSILON)) && animated];
}

- (void)updateImageOverlay:(bool)animated
{
    _imageModel.viewUserInteractionDisabled = (_incoming && _mediaIsAvailable) || !_progressVisible;
    _iconModel.viewUserInteractionDisabled = (_incoming && _mediaIsAvailable) || !_progressVisible;
    
    if (_progressVisible)
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_imageModel setProgress:_progress animated:animated];
        
        [_iconModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_iconModel setProgress:_progress animated:animated];
    }
    else if (!_mediaIsAvailable)
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        [_imageModel setProgress:0.0f animated:false];
        
        [_iconModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        [_iconModel setProgress:0.0f animated:false];
    }
    else
    {
        [_imageModel setOverlayType:TGMessageImageViewOverlayNone animated:animated];
        
        [_iconModel setOverlayType:TGMessageImageViewOverlayNone animated:animated];
    }
}

- (void)imageDataInvalidated:(NSString *)imageUrl
{
    if ([_legacyThumbnailCacheUri isEqualToString:imageUrl])
    {
        [_imageModel reloadImage:false];
    }
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
    [_imageModel boundView].frame = CGRectOffset([_imageModel boundView].frame, itemPosition.x, itemPosition.y);
    (((TGMessageImageViewContainer *)[_imageModel boundView])).imageView.delegate = self;
    
    [_iconModel bindViewToContainer:container viewStorage:viewStorage];
    [_iconModel boundView].frame = CGRectOffset([_iconModel boundView].frame, itemPosition.x, itemPosition.y);
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    (((TGMessageImageViewContainer *)[_imageModel boundView])).imageView.delegate = self;
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    UIView *imageView = [_imageModel boundView];
    ((TGMessageImageViewContainer *)imageView).imageView.delegate = nil;
    
    UIView *iconView = [_iconModel boundView];
    ((TGDocumentMessageIconView *)iconView).delegate = nil;
    
    [super unbindView:viewStorage];
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
    CGSize previewSize = CGSizeZero;
    if (_imageModel != nil)
        previewSize = _imageModel.frame.size;
    else
    {
        previewSize = _iconModel.frame.size;
        previewSize.width -= 4.0f;
        previewSize.height -= 4.0f;
    }
    
    _documentNameModel.frame = CGRectMake(previewSize.width + 14.0f, headerHeight + 28.0f, _documentNameModel.frame.size.width, _documentNameModel.frame.size.height);
    _documentSizeModel.frame = CGRectMake(previewSize.width + 14.0f, headerHeight + 49.0f, _documentSizeModel.frame.size.width, _documentSizeModel.frame.size.height);
    
    _imageModel.frame = CGRectMake(_backgroundModel.frame.origin.x + 10.0f + (_incoming ? 5.0f : 0.0f), _backgroundModel.frame.origin.y + 10.0f + headerHeight, _imageModel.frame.size.width, _imageModel.frame.size.height);
    _iconModel.frame = CGRectMake(_backgroundModel.frame.origin.x + 8.0f + (_incoming ? 5.0f : 0.0f), _backgroundModel.frame.origin.y + 8.0f + headerHeight, _iconModel.frame.size.width, _iconModel.frame.size.height);
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize needsContentsUpdate:(bool *)__unused needsContentsUpdate
{
    CGFloat nameWidth = _documentNameModel.frame.size.width;
    CGFloat sizeWidth = _documentSizeModel.frame.size.width;
    
    CGSize previewSize = CGSizeZero;
    if (_imageModel != nil)
        previewSize = _imageModel.frame.size;
    else
    {
        previewSize = _iconModel.frame.size;
        previewSize.width -= 4.0f;
        previewSize.height -= 4.0f;
    }
    
    return CGSizeMake(MAX(nameWidth, sizeWidth) + previewSize.width + 14.0f, previewSize.height + 10.0f);
}

- (void)messageImageViewActionButtonPressed:(TGMessageImageView *)messageImageView withAction:(TGMessageImageViewActionType)action
{
    if (messageImageView == ((TGMessageImageViewContainer *)[_imageModel boundView]).imageView || messageImageView == [_iconModel boundView])
    {
        if (action == TGMessageImageViewActionCancelDownload)
            [self cancelMediaDownload];
        else
            [self activateMedia];
    }
}

- (void)activateMedia
{
    if (_mediaIsAvailable)
    {
        [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
    }
    else
        [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid)}];
}

- (void)cancelMediaDownload
{
    [_context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid)}];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    return 3;
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            CGPoint point = [recognizer locationInView:[_contentModel boundView]];
            
            if (recognizer.longTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (recognizer.doubleTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point))
                [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @(_forwardedUid)}];
            else
                [self activateMedia];
        }
    }
}

@end
