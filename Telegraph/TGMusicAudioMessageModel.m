#import "TGMusicAudioMessageModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTextMessageBackgroundViewModel.h"
#import "TGDocumentMessageIconModel.h"
#import "TGDocumentMessageIconView.h"
#import "TGWebpageFooterModel.h"

#import "TGMessageImageView.h"
#import "TGModernLabelViewModel.h"

#import "TGModernFlatteningViewModel.h"
#import <LegacyComponents/TGDoubleTapGestureRecognizer.h>
#import "TGModernTextViewModel.h"
#import "TGReplyHeaderModel.h"

#import "TGMusicPlayer.h"

#import "TGReusableLabel.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

#import "TGPresentation.h"

@interface TGMusicAudioMessageModel () <TGMessageImageViewDelegate>
{
    NSArray *_currentLinkSelectionViews;
    TGModernTextViewModel *_textModel;
    TGDocumentMessageIconModel *_iconModel;
    TGModernLabelViewModel *_titleModel;
    TGModernLabelViewModel *_performerModel;
    
    bool _mediaIsAvailable;
    bool _progressVisible;
    float _progress;
    
    bool _isCurrent;
    bool _isPlaying;
    
    CGFloat _headerHeight;
    
    id<SDisposable> _playingAudioMessageIdDisposable;
    CGFloat _previousWidth;
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

@implementation TGMusicAudioMessageModel

- (instancetype)initWithMessage:(TGMessage *)message authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer viaUser:viaUser context:context];
    if (self != nil)
    {
        _authorPeerId = message.fromUid;
        
        _iconModel = [[TGDocumentMessageIconModel alloc] init];
        _iconModel.presentation = context.presentation;
        _iconModel.skipDrawInContext = true;
        _iconModel.frame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
        _iconModel.incoming = _incomingAppearance;
        [self addSubmodel:_iconModel];
        
        NSString *performer = @"";
        NSString *title = @"";
        NSString *fileName = @"";
        NSString *caption = message.caption;
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
            {
                fileName = ((TGDocumentMediaAttachment *)attachment).fileName;
                
                for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                    {
                        TGDocumentAttributeAudio *audioAttribute = attribute;
                        performer = audioAttribute.performer;
                        title = audioAttribute.title;
                        
                        break;
                    }
                }
                break;
            }
        }
        
        if (title.length == 0)
        {
            title = fileName;
            if (title.length == 0)
                title = @"Unknown Track";
        }
        
        if (performer.length == 0)
            performer = @"Unknown Artist";
        
        CGFloat maxWidth = [TGViewController hasLargeScreen] ? 170.0f : 150.0f;
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:caption font:textFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize)];
        _textModel.textCheckingResults = message.textCheckingResults;
        _textModel.underlineAllLinks = _incomingAppearance ? _context.presentation.pallete.underlineAllIncomingLinks : _context.presentation.pallete.underlineAllOutgoingLinks;
        _textModel.textColor = _incomingAppearance ? _context.presentation.pallete.chatIncomingTextColor : _context.presentation.pallete.chatOutgoingTextColor;
        _textModel.linkColor = _incomingAppearance ? _context.presentation.pallete.chatIncomingLinkColor : _context.presentation.pallete.chatOutgoingLinkColor;
        if (message.isBroadcast)
            _textModel.additionalTrailingWidth += 10.0f;
        [_contentModel addSubmodel:_textModel];
        
        _titleModel = [[TGModernLabelViewModel alloc] initWithText:title textColor:_incomingAppearance ? _context.presentation.pallete.chatIncomingAccentColor : _context.presentation.pallete.chatOutgoingAccentColor font:TGCoreTextSystemFontOfSize(16.0f) maxWidth:maxWidth truncateInTheMiddle:false];
        [_contentModel addSubmodel:_titleModel];
        
        _performerModel = [[TGModernLabelViewModel alloc] initWithText:performer textColor:_incomingAppearance ? _context.presentation.pallete.chatIncomingSubtextColor : _context.presentation.pallete.chatOutgoingSubtextColor font:TGCoreTextSystemFontOfSize(13.0f) maxWidth:maxWidth truncateInTheMiddle:false];
        [_contentModel addSubmodel:_performerModel];
        _viaUser = viaUser;
    }
    return self;
}

- (void)updateMediaAvailability:(bool)mediaIsAvailable viewStorage:(TGModernViewStorage *)__unused viewStorage delayDisplay:(bool)delayDisplay
{
    [super updateMediaAvailability:mediaIsAvailable viewStorage:viewStorage delayDisplay:delayDisplay];
    
    _mediaIsAvailable = mediaIsAvailable;
    
    [self updateImageOverlay:false];
}

- (void)updateProgress:(bool)progressVisible progress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated
{
    bool progressWasVisible = _progressVisible;
    float previousProgress = _progress;
    
    [super updateProgress:progressVisible progress:progress viewStorage:viewStorage animated:animated];
    
    _progress = progress;
    _progressVisible = progressVisible;
    
    [self updateImageOverlay:((progressWasVisible && !_progressVisible) || (_progressVisible && ABS(_progress - previousProgress) > FLT_EPSILON)) && animated];
}

- (void)updateImageOverlay:(bool)animated
{
    //_iconModel.viewUserInteractionDisabled = (_incoming && _mediaIsAvailable) || !_progressVisible;
    
    if (_progressVisible || _deliveryState == TGMessageDeliveryStatePending)
    {
        [_iconModel setOverlayType:TGMessageImageViewOverlayProgress animated:false];
        [_iconModel setProgress:_progress animated:animated];
    }
    else if (!_mediaIsAvailable)
    {
        [_iconModel setOverlayType:TGMessageImageViewOverlayDownload animated:false];
        [_iconModel setProgress:0.0f animated:false];
    }
    else
    {
        [_iconModel setOverlayType:_isPlaying ? TGMessageImageViewOverlayPauseMedia : TGMessageImageViewOverlayPlayMedia animated:animated];
    }
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    bool wasDelivering = _deliveryState == TGMessageDeliveryStatePending;
    
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    if (wasDelivering != (_deliveryState == TGMessageDeliveryStatePending)) {
        [self updateImageOverlay:false];
    }
    
    NSString *caption = message.caption;
    if (!TGStringCompare(_textModel.text, caption)) {
        _textModel.text = caption;
        _textModel.textCheckingResults = message.textCheckingResults;
        if (sizeUpdated != NULL)
            *sizeUpdated = true;
    }
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
    _headerHeight = headerHeight;
    
    if (_textModel.text.length != 0 && ![_textModel.text isEqualToString:@" "]) {
        CGRect textFrame = _textModel.frame;
        
        CGFloat textInset = _iconModel.frame.size.height - 8.0f;
        textFrame.origin = CGPointMake(1, textInset + headerHeight);
        _textModel.frame = textFrame;
        headerHeight += textFrame.size.height;
    } else {
        _textModel.frame = CGRectZero;
    }
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_iconModel bindViewToContainer:container viewStorage:viewStorage];
    [_iconModel boundView].frame = CGRectOffset([_iconModel boundView].frame, itemPosition.x, itemPosition.y);
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    [self subscribeToStatus];
}

- (void)subscribeToStatus {
    [_playingAudioMessageIdDisposable dispose];
    if (_context.playingAudioMessageStatus != nil)
    {
        __weak TGMusicAudioMessageModel *weakSelf = self;
        _playingAudioMessageIdDisposable = [_context.playingAudioMessageStatus startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGMusicAudioMessageModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                int32_t mid = [(NSNumber *)status.item.key intValue];;
                int paused = status.paused;
                
                bool isCurrent = mid == strongSelf->_mid;
                bool isPlaying = isCurrent && (paused == 0);
                
                if (isPlaying != strongSelf->_isPlaying || isCurrent != strongSelf->_isCurrent)
                {
                    strongSelf->_isPlaying = isPlaying;
                    strongSelf->_isCurrent = isCurrent;
                    [strongSelf updateImageOverlay:false];
                }
            }
        }];
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    ((TGDocumentMessageIconView *)[_iconModel boundView]).delegate = self;
    
    [self subscribeToStatus];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [_playingAudioMessageIdDisposable dispose];
    
    UIView *iconView = [_iconModel boundView];
    ((TGDocumentMessageIconView *)iconView).delegate = nil;
    
    [super unbindView:viewStorage];
    
    _isPlaying = false;
    _isCurrent = false;
    [self updateImageOverlay:false];
    
    [self clearLinkSelection];
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)infoWidth
{
    CGFloat additionalWidth = 0.0f;
    if (_performerModel.frame.size.width < _titleModel.frame.size.width)
        additionalWidth += MAX(0.0f, 30.0f - _titleModel.frame.size.width - _performerModel.frame.size.width);
    
    if (ABS(_previousWidth - containerSize.width) > FLT_EPSILON) {
        _previousWidth = containerSize.width;
        if (needsContentsUpdate) {
            *needsContentsUpdate = true;
        }
    }
    
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
    
    if (_textModel.text.length != 0 && ![_textModel.text isEqualToString:@" "]) {
        textSize = _textModel.frame.size;
        textSize.height += 8.0f;
    } else {
        //textSize.width = MAX(textSize.width, MIN(containerSize.width, infoWidth + sizeWidth + previewSize.width + 16.0f));
    }
    
    CGSize size = CGSizeMake(MIN(containerSize.width + 28.0f, MAX(textSize.width, 57.0f + 10.0f + MAX(_titleModel.frame.size.width, _performerModel.frame.size.width) + 20.0f)), 59.0f + textSize.height);
    if (infoWidth > size.width - 40.0f) {
        size.height += 10.0f;
    }
    return size;
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
    
    _iconModel.frame = CGRectMake(_contentModel.frame.origin.x - 5.0f, _headerHeight + _contentModel.frame.origin.y + 2.0f, _iconModel.frame.size.width, _iconModel.frame.size.height);
    _titleModel.frame = CGRectMake(57.0f, _headerHeight + 10.0f, _titleModel.frame.size.width, _titleModel.frame.size.height);
    _performerModel.frame = CGRectMake(57.0f, _headerHeight + 31.0f, _performerModel.frame.size.width, _performerModel.frame.size.height);
}

- (void)messageImageViewActionButtonPressed:(TGMessageImageView *)messageImageView withAction:(TGMessageImageViewActionType)action
{
    if (messageImageView == [_iconModel boundView])
    {
        if (action == TGMessageImageViewActionCancelDownload) {
            [self cancelMediaDownload];
        }
        else
            [self activateMedia];
    }
}

- (void)activateMedia
{
    if (_mediaIsAvailable)
    {
        if (_isPlaying)
        {
            if (_context.pauseAudioMessage)
                _context.pauseAudioMessage();
        }
        else if (_isCurrent)
        {
            if (_context.resumeAudioMessage)
                _context.resumeAudioMessage();
        }
        else
        {
            if (_context.playAudioMessageId)
                _context.playAudioMessageId(_mid);
        }
    }
    else
        [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
}

- (void)cancelMediaDownload
{
    [_context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
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
        
        if (link == NULL)
        {
            if (_webPageFooterModel != nil)
            {
                CGFloat heightOffset = _textModel.frame.origin.y;
                
                link = [_webPageFooterModel linkAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x - offset.x, point.y - _webPageFooterModel.frame.origin.y - offset.y) regionData:&regionData];
                regionOffset = _webPageFooterModel.frame.origin;
                
                regionOffset.y -= heightOffset;
            }
        }
        
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

- (UIScrollView *)findScrollView {
    UIView *superview = [_backgroundModel.boundView superview];
    while (superview != nil) {
        if ([superview isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)superview;
        }
        superview = [superview superview];
    }
    return nil;
}

//- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
//{
//    if (recognizer.state != UIGestureRecognizerStateBegan)
//    {
//        if (recognizer.state == UIGestureRecognizerStateRecognized)
//        {
//            CGPoint point = [recognizer locationInView:[_contentModel boundView]];
//
//            if (recognizer.longTapped)
//                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
//            else if (recognizer.doubleTapped)
//                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
//            else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) {
//                if (_viaUser != nil && [_forwardedHeaderModel linkAtPoint:CGPointMake(point.x - _forwardedHeaderModel.frame.origin.x, point.y - _forwardedHeaderModel.frame.origin.y) regionData:NULL]) {
//                    [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
//                } else {
//                    if (TGPeerIdIsChannel(_forwardedPeerId)) {
//                        [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
//                    } else {
//                        [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
//                    }
//                }
//            }
//            else if (_viaUserModel != nil && CGRectContainsPoint(_viaUserModel.frame, point)) {
//                [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
//            }
//            else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
//                [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
//            else if (_textModel.frame.size.height <= FLT_EPSILON || point.y < CGRectGetMinY(_textModel.frame)) {
//                [self activateMedia];
//            }
//        }
//    }
//}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        [self clearLinkSelection];
        
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            CGPoint point = [recognizer locationInView:[_contentModel boundView]];
            bool hiddenLink = false;
            NSString *linkCandidateText = nil;
            NSString *linkCandidate = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL hiddenLink:&hiddenLink linkText:&linkCandidateText];
            if ([linkCandidate hasPrefix:@"http://telegra.ph/"] || [linkCandidate hasPrefix:@"https://telegra.ph/"]) {
                hiddenLink = false;
            }
            TGWebPageMediaAttachment *webPage = nil;
            bool activateWebpageContents = false;
            TGWebpageFooterModelAction webpageAction = TGWebpageFooterModelActionNone;
            bool webpageIsVideo = false;
            bool webpageIsGame = false;
            bool webpageIsInvoice = false;
            if ([_webPage.pageType isEqualToString:@"game"]) {
                webpageIsGame = true;
            } else if ([_webPage.pageType isEqualToString:@"invoice"]) {
                webpageIsInvoice = true;
            } else if (_webPage.document != nil) {
                bool isVideo = false;
                bool isAnimation = false;
                for (id attribute in _webPage.document.attributes) {
                    if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                        isVideo = true;
                    } else if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                        isAnimation = true;
                    }
                }
                webpageIsVideo = isVideo && !isAnimation;
            }
            
            bool isCoub = [_webPage.siteName.lowercaseString isEqualToString:@"coub"];
            bool isInstagram = [_webPage.siteName.lowercaseString isEqualToString:@"instagram"];
            bool isTwitter = [_webPage.siteName.lowercaseString isEqualToString:@"twitter"];
            bool isInstantGallery = [_webPage.pageType isEqualToString:@"telegram_album"] || ((isTwitter || isInstagram) && _webPage.instantPage != nil);
            
            bool activateVideo = false;
            bool activateGame = false;
            bool activateInvoice = false;
            bool activateInstantPage = false;
            bool activateRoundMessage = false;
            if (linkCandidate == nil)
            {
                if (_webPageFooterModel != nil && CGRectContainsPoint(_webPageFooterModel.frame, point))
                {
                    webpageAction = [_webPageFooterModel webpageActionAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y)];
                    if (webpageAction != TGWebpageFooterModelActionNone)
                    {
                        if (webpageIsGame) {
                            activateGame = true;
                        } else if (webpageIsInvoice) {
                            activateInvoice = true;
                        } else if (_webPage.instantPage != nil && webpageAction != TGWebpageFooterModelActionDownload && !isInstantGallery) {
                            activateInstantPage = true;
                        } else if (_webPage.document.isRoundVideo && webpageAction != TGWebpageFooterModelActionDownload) {
                            activateRoundMessage = true;
                        } else {
                            if ([_webPage.pageType isEqualToString:@"photo"] || [_webPage.pageType isEqualToString:@"article"] || (isInstantGallery && _webPage.instantPage != nil))
                                webPage = _webPage;
                            
                            activateWebpageContents = _webPage.embedUrl.length != 0;
                            if (webpageAction == TGWebpageFooterModelActionDownload || webpageAction == TGWebpageFooterModelActionCancel) {
                            } else if (_webPageFooterModel.mediaIsAvailable) {
                                if (webpageIsVideo && !isInstantGallery) {
                                    activateVideo = true;
                                }
                            }
                            
                            if (isInstantGallery || isInstagram)
                                webpageAction = TGWebpageFooterModelActionNone;
                            else if ((webpageAction == TGWebpageFooterModelActionDownload || (webpageAction == TGWebpageFooterModelActionPlay && (_context.autoplayAnimations || isCoub))) && _webPageFooterModel.mediaIsAvailable) {
                                webpageAction = TGWebpageFooterModelActionNone;
                            }
                            linkCandidate = _webPage.url;
                        }
                    }
                    else
                    {
                        linkCandidate = [_webPageFooterModel linkAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y) regionData:NULL];
                    }
                }
            }
            if (_webPage.instantPage != nil && !isInstantGallery && ([linkCandidate hasPrefix:@"http://telegra.ph/"] || [linkCandidate hasPrefix:@"https://telegra.ph/"] || [linkCandidate hasPrefix:@"http://t.me/iv?"] || [linkCandidate hasPrefix:@"https://t.me/iv?"]) && webpageAction != TGWebpageFooterModelActionDownload) {
                if ([_webPage.url isEqualToString:linkCandidate] || (linkCandidateText != nil && [_webPage.url isEqualToString:linkCandidateText])) {
                    activateInstantPage = true;
                }
            }
            
            if (hiddenLink && ([linkCandidate hasPrefix:@"http://telegram.me/"] || [linkCandidate hasPrefix:@"http://t.me/"] || [linkCandidate hasPrefix:@"https://telegram.me/"] || [linkCandidate hasPrefix:@"https://t.me/"])) {
                hiddenLink = false;
            }
            
            if (recognizer.longTapped)
            {
                if (linkCandidate != nil) {
                    if (_webPage != nil) {
                        [_context.companionHandle requestAction:@"openLinkWithOptionsRequested" options:@{@"url": linkCandidate, @"webPage": _webPage}];
                    } else {
                        [_context.companionHandle requestAction:@"openLinkWithOptionsRequested" options:@{@"url": linkCandidate}];
                    }
                }
                else
                    [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
            }
            else if (recognizer.doubleTapped) {
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
            } else if (activateRoundMessage) {
                [_webPageFooterModel activateMediaPlayback];
            } else if (activateVideo) {
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
            } else if (activateGame) {
                [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": [NSString stringWithFormat:@"activate-app://%d", _mid]}];
            } else if (activateInvoice) {
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
            } else if (activateInstantPage) {
                [self instantPageButtonPressed];
            } else if (webpageAction == TGWebpageFooterModelActionDownload) {
                [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
            } else if (webpageAction == TGWebpageFooterModelActionCancel) {
                [_context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
            } else if (webpageAction == TGWebpageFooterModelActionPlay) {
                [_webPageFooterModel activateWebpageContents];
            } else if (webpageAction == TGWebpageFooterModelActionOpenMedia) {
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
            }
            else if (webpageAction == TGWebpageFooterModelActionCustom) {
                [_webPageFooterModel activateWebpageContents];
            } else if (webpageAction == TGWebpageFooterModelActionOpenURL && linkCandidate != nil) {
                [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": linkCandidate, @"mid": @(_mid)}];
            }
            else if (activateWebpageContents)
                [_context.companionHandle requestAction:@"openEmbedRequested" options:@{@"webPage": _webPage, @"mid": @(_mid)}];
            else if (webPage != nil)
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid), @"peerId": @(_authorPeerId)}];
            else if (linkCandidate != nil)
                [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": linkCandidate, @"mid": @(_mid), @"hidden": @(hiddenLink)}];
            else if (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) {
                if (_viaUser != nil && [_forwardedHeaderModel linkAtPoint:CGPointMake(point.x - _forwardedHeaderModel.frame.origin.x, point.y - _forwardedHeaderModel.frame.origin.y) regionData:NULL]) {
                    [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
                } else {
                    if (TGPeerIdIsChannel(_forwardedPeerId)) {
                        [_context.companionHandle requestAction:@"peerAvatarTapped" options:@{@"peerId": @(_forwardedPeerId), @"messageId": @(_forwardedMessageId)}];
                    } else {
                        [_context.companionHandle requestAction:@"userAvatarTapped" options:@{@"uid": @((int32_t)_forwardedPeerId)}];
                    }
                }
            }
            else if (_viaUserModel != nil && CGRectContainsPoint(_viaUserModel.frame, point)) {
                [_context.companionHandle requestAction:@"useContextBot" options:@{@"uid": @((int32_t)_viaUser.uid), @"username": _viaUser.userName == nil ? @"" : _viaUser.userName}];
            }
            else if (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point))
                [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_replyMessageId), @"sourceMid": @(_mid)}];
            else if (_textModel.frame.size.height <= FLT_EPSILON || point.y < CGRectGetMinY(_textModel.frame)) {
                [self activateMedia];
            }
        }
    }
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)point
{
    point = [recognizer locationInView:[_contentModel boundView]];
    
    if ([_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL] != nil ||
        (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) || (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point)) ||
        (_viaUserModel && CGRectContainsPoint(_viaUserModel.frame, point)))
        return 3;
    
    if (_webPageFooterModel != nil && CGRectContainsPoint(_webPageFooterModel.frame, point))
    {
        if ([_webPageFooterModel webpageActionAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y)] != TGWebpageFooterModelActionNone)
        {
            return 3;
        }
        
        if ([_webPageFooterModel linkAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y) regionData:NULL] != nil)
        {
            return 3;
        }
        
        if (_webPage.instantPage != nil) {
            return 3;
        }
    }
    
    if (_textModel.frame.size.height < FLT_EPSILON || point.y < CGRectGetMinY(_textModel.frame)) {
        return 3;
    }
    
    return false;
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)point
{
    if (![self findScrollView].isDecelerating) {
        [self updateLinkSelection:point];
    }
}

- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    [self clearLinkSelection];
}

- (void)clearHighlights
{
    [self clearLinkSelection];
}

@end
