#import "TGDocumentMessageViewModel.h"

#import "TGMessage.h"
#import "TGPeerIdAdapter.h"

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
#import "TGStringUtils.h"
#import "TGFont.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGDoubleTapGestureRecognizer.h"

#import "TGReplyHeaderModel.h"

#import "TGSharedMediaFileThumbnailView.h"

#import "TGAppDelegate.h"

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
    
    NSString *_titleText;
    NSString *_sizeText;
}

@end

@implementation TGDocumentMessageViewModel

- (NSString *)filePathForDocumentId:(int64_t)documentId local:(bool)local
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
        filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"file"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filesDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:filesDirectory withIntermediateDirectories:true attributes:nil error:nil];
    });
    
    return [filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", documentId]];
}

- (instancetype)initWithMessage:(TGMessage *)message document:(TGDocumentMediaAttachment *)document authorPeer:(id)authorPeer context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer context:context];
    if (self != nil)
    {
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
        dispatch_once(&onceToken, ^
        {
            incomingNameColor = UIColorRGB(0x0b8bed);
            outgoingNameColor = UIColorRGB(0x3faa3c);
            incomingSizeColor = UIColorRGB(0x999999);
            outgoingSizeColor = UIColorRGB(0x6fb26a);
        });
        
        _titleText = document.fileName;
        
        _documentNameModel = [[TGModernLabelViewModel alloc] initWithText:@"" textColor:_incomingAppearance ? incomingNameColor : outgoingNameColor font:TGCoreTextSystemFontOfSize(16.0f) maxWidth:145.0f truncateInTheMiddle:true];
        [_contentModel addSubmodel:_documentNameModel];
        
        NSString *sizeString = @"";
        if (document.size >= 1024 * 1024)
        {
            sizeString = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.Megabytes"), (float)(float)document.size / (1024 * 1024)];
        }
        else if (document.size >= 1024)
        {
            sizeString = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.Kilobytes"), (int)(int)(document.size / 1024)];
        }
        else
        {
            sizeString = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.Bytes"), (int)(int)(document.size)];
        }
        
        _sizeText = sizeString;
        
        _documentSizeModel = [[TGModernLabelViewModel alloc] initWithText:@"" textColor:!_incomingAppearance ? outgoingSizeColor : incomingSizeColor font:TGCoreTextSystemFontOfSize(13.0f) maxWidth:145.0f];
        [_contentModel addSubmodel:_documentSizeModel];
        
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
            _iconModel.incoming = _incomingAppearance;
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
    
    if (_imageModel != nil)
    {
        _documentNameModel.frame = CGRectMake(previewSize.width + 14.0f, headerHeight + 22.0f, _documentNameModel.frame.size.width, _documentNameModel.frame.size.height);
        _documentSizeModel.frame = CGRectMake(previewSize.width + 14.0f, headerHeight + 45.0f, _documentSizeModel.frame.size.width, _documentSizeModel.frame.size.height);
    }
    else
    {
        _documentNameModel.frame = CGRectMake(previewSize.width + 1.0f, headerHeight + 10.0f - TGRetinaPixel, _documentNameModel.frame.size.width, _documentNameModel.frame.size.height);
        _documentSizeModel.frame = CGRectMake(previewSize.width + 1.0f, headerHeight + 32.0f - TGRetinaPixel, _documentSizeModel.frame.size.width, _documentSizeModel.frame.size.height);
    }
    
    _imageModel.frame = CGRectMake(_backgroundModel.frame.origin.x + 9.0f + (_incomingAppearance ? 5.0f : 0.0f), _backgroundModel.frame.origin.y + 9.0f + headerHeight, _imageModel.frame.size.width, _imageModel.frame.size.height);
    _iconModel.frame = CGRectMake(_backgroundModel.frame.origin.x + 4.0f + (_incomingAppearance ? 5.0f : 0.0f), _backgroundModel.frame.origin.y + 4.0f + headerHeight, _iconModel.frame.size.width, _iconModel.frame.size.height);
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate hasDate:(bool)__unused hasDate hasViews:(bool)__unused hasViews
{
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
    
    [_documentNameModel setText:_titleText maxWidth:containerSize.width - previewSize.width - 16.0f needsContentUpdate:needsContentsUpdate];
    [_documentSizeModel setText:_sizeText maxWidth:containerSize.width - previewSize.width - 16.0f needsContentUpdate:needsContentsUpdate];
    
    CGFloat nameWidth = _documentNameModel.frame.size.width;
    CGFloat sizeWidth = _documentSizeModel.frame.size.width;
    
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
            else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) {
                if (TGPeerIdIsChannel(_forwardedPeerId)) {
                    [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
                } else {
                    [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
                }
            }
            else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
                [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
            else
                [self activateMedia];
        }
    }
}

@end
