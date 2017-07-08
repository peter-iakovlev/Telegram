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

#import "TGReusableLabel.h"

@interface TGDocumentMessageViewModel () <TGMessageImageViewDelegate>
{
    NSString *_legacyThumbnailCacheUri;
    bool _mediaIsAvailable;
    bool _progressVisible;
    float _progress;
    
    TGModernTextViewModel *_textModel;
    TGModernLabelViewModel *_documentNameModel;
    TGModernLabelViewModel *_documentSizeModel;
    TGMessageImageViewModel *_imageModel;
    TGDocumentMessageIconModel *_iconModel;
    
    NSString *_titleText;
    NSString *_sizeText;
    
    NSArray *_currentLinkSelectionViews;
    NSArray *_textCheckingResults;
}

@end

static CTFontRef textFontForSize(CGFloat size)
{
    static CTFontRef font = NULL;
    static int cachedSize = 0;
    
    if ((int)size != cachedSize || font == NULL)
    {
        font = TGCoreTextSystemFontOfSize(size);
        cachedSize = (int)size;
    }
    
    return font;
}

@implementation TGDocumentMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message document:(TGDocumentMediaAttachment *)document authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer viaUser:viaUser context:context];
    if (self != nil)
    {
        _textCheckingResults = document.textCheckingResults;
        
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
        
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        static dispatch_once_t onceToken2;
        dispatch_once(&onceToken2, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
        });
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:document.caption font:textFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize)];
        _textModel.textCheckingResults = _textCheckingResults;
        _textModel.textColor = [assetsSource messageTextColor];
        if (message.isBroadcast)
            _textModel.additionalTrailingWidth += 10.0f;
        [_contentModel addSubmodel:_textModel];
        
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

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    NSArray *currentTextCheckingResults = nil;
    TGDocumentMediaAttachment *document = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            document = (TGDocumentMediaAttachment *)attachment;
            currentTextCheckingResults = document.textCheckingResults;
            break;
        }
    }
    
    if (document == nil)
        return;
    
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
    
    if (!TGStringCompare(_textModel.text, document.caption)) {
        _textCheckingResults = currentTextCheckingResults;
        
        _textModel.text = document.caption;
        _textModel.textCheckingResults = currentTextCheckingResults;
        if (sizeUpdated != NULL)
            *sizeUpdated = true;
    }
    
    _sizeText = sizeString;
    if (sizeUpdated != NULL)
        *sizeUpdated = true;
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage delayDisplay:(bool)delayDisplay
{   
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage delayDisplay:delayDisplay];
    
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
    
    if (_textModel.text.length != 0 && ![_textModel.text isEqualToString:@" "]) {
        CGRect textFrame = _textModel.frame;
        
        CGFloat textInset = 0.0f;
        if (_imageModel != nil) {
            textInset = CGRectGetMaxY(_imageModel.frame) - 2.0f;
        } else {
            textInset = CGRectGetMaxY(_iconModel.frame) - 8.0f;
        }
        textFrame.origin = CGPointMake(1, textInset);
        _textModel.frame = textFrame;
        headerHeight += textFrame.size.height;
    } else {
        _textModel.frame = CGRectZero;
    }
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)infoWidth
{
    CGSize textSize = CGSizeZero;
    
    int layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    
    if (_context.commandsEnabled)
        layoutFlags |= TGReusableLabelLayoutHighlightCommands;
    
    bool updateContents = [_textModel layoutNeedsUpdatingForContainerSize:containerSize additionalTrailingWidth:infoWidth layoutFlags:layoutFlags];
    _textModel.layoutFlags = layoutFlags;
    _textModel.additionalTrailingWidth = infoWidth;
    if (updateContents)
        [_textModel layoutForContainerSize:containerSize];
    
    if (needsContentsUpdate != NULL && updateContents)
        *needsContentsUpdate = updateContents;
    
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
    
    if (_textModel.text.length != 0 && ![_textModel.text isEqualToString:@" "]) {
        textSize = _textModel.frame.size;
        if (_imageModel != nil) {
            textSize.height += 2.0f;
        } else {
            textSize.height += 8.0f;
        }
        if (infoWidth < FLT_EPSILON) {
            textSize.height -= 15.0f;
        }
    } else {
        textSize.width = MAX(textSize.width, MIN(containerSize.width, infoWidth + sizeWidth + previewSize.width + 16.0f));
        
        if (infoWidth < FLT_EPSILON) {
            textSize.height -= 12.0f;
        }
    }
    
    if (_authorSignatureModel != nil) {
        previewSize.height += 14.0f;
    }
    
    return CGSizeMake(MAX(textSize.width, MAX(nameWidth, sizeWidth) + previewSize.width + 14.0f), previewSize.height + 10.0f + textSize.height);
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

- (void)clearLinkSelection
{
    for (UIView *linkView in _currentLinkSelectionViews)
    {
        [linkView removeFromSuperview];
    }
    _currentLinkSelectionViews = nil;
}

- (void)updateLinkSelection:(CGPoint)point
{
    if ([_contentModel boundView] != nil)
    {
        [self clearLinkSelection];
        
        CGPoint offset = CGPointMake(_contentModel.frame.origin.x - _backgroundModel.frame.origin.x, _contentModel.frame.origin.y - _backgroundModel.frame.origin.y);
        
        NSArray *regionData = nil;
        NSString *link = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x - offset.x, point.y - _textModel.frame.origin.y - offset.y) regionData:&regionData];
        
        CGPoint regionOffset = CGPointZero;
        
        if (link != nil)
        {
            CGRect topRegion = regionData.count > 0 ? [regionData[0] CGRectValue] : CGRectZero;
            CGRect middleRegion = regionData.count > 1 ? [regionData[1] CGRectValue] : CGRectZero;
            CGRect bottomRegion = regionData.count > 2 ? [regionData[2] CGRectValue] : CGRectZero;
            
            topRegion.origin = CGPointMake(topRegion.origin.x + regionOffset.x, topRegion.origin.y + regionOffset.y);
            middleRegion.origin = CGPointMake(middleRegion.origin.x + regionOffset.x, middleRegion.origin.y + regionOffset.y);
            bottomRegion.origin = CGPointMake(bottomRegion.origin.x + regionOffset.x, bottomRegion.origin.y + regionOffset.y);
            
            UIImageView *topView = nil;
            UIImageView *middleView = nil;
            UIImageView *bottomView = nil;
            
            UIImageView *topCornerLeft = nil;
            UIImageView *topCornerRight = nil;
            UIImageView *bottomCornerLeft = nil;
            UIImageView *bottomCornerRight = nil;
            
            NSMutableArray *linkHighlightedViews = [[NSMutableArray alloc] init];
            
            topView = [[UIImageView alloc] init];
            middleView = [[UIImageView alloc] init];
            bottomView = [[UIImageView alloc] init];
            
            topCornerLeft = [[UIImageView alloc] init];
            topCornerRight = [[UIImageView alloc] init];
            bottomCornerLeft = [[UIImageView alloc] init];
            bottomCornerRight = [[UIImageView alloc] init];
            
            if (topRegion.size.height != 0)
            {
                topView.hidden = false;
                topView.frame = topRegion;
                if (middleRegion.size.height == 0 && bottomRegion.size.height == 0)
                    topView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
                else
                    topView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
            }
            else
            {
                topView.hidden = true;
                topView.frame = CGRectZero;
            }
            
            if (middleRegion.size.height != 0)
            {
                middleView.hidden = false;
                middleView.frame = middleRegion;
                if (bottomRegion.size.height == 0)
                    middleView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
                else
                    middleView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
            }
            else
            {
                middleView.hidden = true;
                middleView.frame = CGRectZero;
            }
            
            if (bottomRegion.size.height != 0)
            {
                bottomView.hidden = false;
                bottomView.frame = bottomRegion;
                bottomView.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
            }
            else
            {
                bottomView.hidden = true;
                bottomView.frame = CGRectZero;
            }
            
            topCornerLeft.hidden = true;
            topCornerRight.hidden = true;
            bottomCornerLeft.hidden = true;
            bottomCornerRight.hidden = true;
            
            if (topRegion.size.height != 0 && middleRegion.size.height != 0)
            {
                if (topRegion.origin.x == middleRegion.origin.x)
                {
                    topCornerLeft.hidden = false;
                    topCornerLeft.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerLR];
                    topCornerLeft.frame = CGRectMake(topRegion.origin.x, topRegion.origin.y + topRegion.size.height - 3.5f, 4, 7);
                }
                else if (topRegion.origin.x < middleRegion.origin.x + middleRegion.size.width - 3.5f)
                {
                    topCornerLeft.hidden = false;
                    topCornerLeft.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerBT];
                    topCornerLeft.frame = CGRectMake(topRegion.origin.x - 3.5f, topRegion.origin.y + topRegion.size.height - 4, 7, 4);
                }
                
                if (topRegion.origin.x + topRegion.size.width == middleRegion.origin.x + middleRegion.size.width)
                {
                    topCornerRight.hidden = false;
                    topCornerRight.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerRL];
                    topCornerRight.frame = CGRectMake(topRegion.origin.x + topRegion.size.width - 4, topRegion.origin.y + topRegion.size.height - 3.5f, 4, 7);
                }
                else if (topRegion.origin.x + topRegion.size.width < middleRegion.origin.x + middleRegion.size.width - 3.5f)
                {
                    topCornerRight.hidden = false;
                    topCornerRight.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerBT];
                    topCornerRight.frame = CGRectMake(topRegion.origin.x + topRegion.size.width - 3.5f, topRegion.origin.y + topRegion.size.height - 4, 7, 4);
                }
                else if (bottomRegion.size.height == 0 && topRegion.origin.x < middleRegion.origin.x + middleRegion.size.width - 3.5f && topRegion.origin.x + topRegion.size.width > middleRegion.origin.x + middleRegion.size.width + 3.5f)
                {
                    topCornerRight.hidden = false;
                    topCornerRight.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerTB];
                    topCornerRight.frame = CGRectMake(middleRegion.origin.x + middleRegion.size.width - 3.5f, middleRegion.origin.y, 7, 4);
                }
            }
            
            if (middleRegion.size.height != 0 && bottomRegion.size.height != 0)
            {
                if (middleRegion.origin.x == bottomRegion.origin.x)
                {
                    bottomCornerLeft.hidden = false;
                    bottomCornerLeft.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerLR];
                    bottomCornerLeft.frame = CGRectMake(middleRegion.origin.x, middleRegion.origin.y + middleRegion.size.height - 3.5f, 4, 7);
                }
                
                if (bottomRegion.origin.x + bottomRegion.size.width < middleRegion.origin.x + middleRegion.size.width - 3.5f)
                {
                    bottomCornerRight.hidden = false;
                    bottomCornerRight.image = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkCornerTB];
                    bottomCornerRight.frame = CGRectMake(bottomRegion.origin.x + bottomRegion.size.width - 3.5f, bottomRegion.origin.y, 7, 4);
                }
            }
            
            if (!topView.hidden)
                [linkHighlightedViews addObject:topView];
            if (!middleView.hidden)
                [linkHighlightedViews addObject:middleView];
            if (!bottomView.hidden)
                [linkHighlightedViews addObject:bottomView];
            
            if (!topCornerLeft.hidden)
                [linkHighlightedViews addObject:topCornerLeft];
            if (!topCornerRight.hidden)
                [linkHighlightedViews addObject:topCornerRight];
            if (!bottomCornerLeft.hidden)
                [linkHighlightedViews addObject:bottomCornerLeft];
            if (!bottomCornerRight.hidden)
                [linkHighlightedViews addObject:bottomCornerRight];
            
            for (UIView *partView in linkHighlightedViews)
            {
                partView.frame = CGRectOffset(partView.frame, _textModel.frame.origin.x, _textModel.frame.origin.y + 1);
                [[_contentModel boundView] addSubview:partView];
            }
            
            _currentLinkSelectionViews = linkHighlightedViews;
        }
    }
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)__unused point
{
    CGPoint convertedPoint = [recognizer locationInView:[_contentModel boundView]];
    
    if (_textModel.frame.size.height > FLT_EPSILON && point.y >= CGRectGetMinY(_textModel.frame)) {
        if (([_textModel linkAtPoint:CGPointMake(convertedPoint.x - _textModel.frame.origin.x, convertedPoint.y - _textModel.frame.origin.y) regionData:NULL] != nil || (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, convertedPoint)) || (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, convertedPoint)) ||
             (_viaUserModel && CGRectContainsPoint(_viaUserModel.frame, convertedPoint)))) {
            return 3;
        }
        
        return 0;
    }
    
    return 3;
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)point
{
    [self updateLinkSelection:point];
}

- (bool)gestureRecognizerShouldLetScrollViewStealTouches:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    [self clearLinkSelection];
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        [self clearLinkSelection];
    }
    
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint point = [recognizer locationInView:[_contentModel boundView]];
        NSString *linkCandidate = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL];
        
        if (recognizer.longTapped)
        {
            if (linkCandidate != nil)
                [_context.companionHandle requestAction:@"openLinkWithOptionsRequested" options:@{@"url": linkCandidate}];
            else
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
        }
        else if (recognizer.doubleTapped)
            [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
        else if (linkCandidate != nil)
            [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": linkCandidate, @"mid": @(_mid)}];
        else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) {
            if (TGPeerIdIsChannel(_forwardedPeerId)) {
                [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
            } else {
                [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
            }
        }
        else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
            [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
        else if (_textModel.frame.size.height <= FLT_EPSILON || point.y < CGRectGetMinY(_textModel.frame)) {
            [self activateMedia];
        }
    }
}

- (bool)isPreviewableAtPoint:(CGPoint)__unused point
{
    return (_imageModel != nil);
}

- (NSString *)linkAtPoint:(CGPoint)point {
    point.x -= _contentModel.frame.origin.x;
    point.y -= _contentModel.frame.origin.y;
    return [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL];
}

@end
