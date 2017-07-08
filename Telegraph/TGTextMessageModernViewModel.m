#import "TGTextMessageModernViewModel.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGPeerIdAdapter.h"

#import "TGImageUtils.h"
#import "TGDateUtils.h"
#import "TGStringUtils.h"
#import "TGFont.h"

#import "TGModernConversationItem.h"
#import "TGModernView.h"

#import "TGModernFlatteningViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGModernLabelViewModel.h"
#import "TGModernDateViewModel.h"
#import "TGModernRemoteImageViewModel.h"
#import "TGModernClockProgressViewModel.h"
#import "TGTextMessageBackgroundViewModel.h"

#import "TGReusableLabel.h"

#import "TGMessage.h"
#import "TGUser.h"

#import "TGReplyHeaderModel.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "TGWebpageFooterModel.h"
#import "TGTextCheckingResult.h"

@interface TGTextMessageModernViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate>
{
    TGModernTextViewModel *_textModel;
    bool _textIsRTL;
    
    NSArray *_currentLinkSelectionViews;
    bool _isBot;
    
    NSArray *_currentSearchHighlightViews;
    NSString *_text;
    bool _emojiOnly;
    bool _centerText;
    bool _isGame;
    bool _isInvoice;
}

@end

@implementation TGTextMessageModernViewModel

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

static NSString *expandedTextAndAttributes(NSString *text, NSArray *textCheckingResults, __autoreleasing NSArray **updatedTextCheckingResults) {
    return text;
    
    if (textCheckingResults.count != 0) {
        NSMutableArray<NSNumber *> *stringResults = nil;
        NSMutableArray<NSString *> *stringValues = nil;
        NSInteger index = -1;
        for (id result in textCheckingResults) {
            index++;
            if ([result isKindOfClass:[NSTextCheckingResult class]]) {
                if (((NSTextCheckingResult *)result).resultType == NSTextCheckingTypeLink) {
                    NSRange range = ((NSTextCheckingResult *)result).range;
                    if (range.location + range.length <= text.length) {
                        NSString *link = [text substringWithRange:range];
                        NSString *decodedLink = [link stringByRemovingPercentEncoding];
                        if (![link isEqualToString:decodedLink] && decodedLink.length != 0) {
                            if (stringResults == nil) {
                                stringResults = [[NSMutableArray alloc] init];
                                stringValues = [[NSMutableArray alloc] init];
                            }
                            [stringResults addObject:@(index)];
                            [stringValues addObject:decodedLink];
                        }
                    }
                }
            }
        }
        if (stringResults.count != 0) {
            NSMutableArray *updatedResults = [[NSMutableArray alloc] initWithArray:textCheckingResults];
            NSMutableString *updatedString = [[NSMutableString alloc] initWithString:text];
            
            NSInteger index = -1;
            for (NSNumber *resultIndex in stringResults) {
                index++;
                NSTextCheckingResult *result = updatedResults[resultIndex.integerValue];
                NSString *decodedString = stringValues[index];
                
                [updatedString replaceCharactersInRange:result.range withString:decodedString];
                updatedResults[resultIndex.integerValue] = [NSTextCheckingResult linkCheckingResultWithRange:NSMakeRange(result.range.location, decodedString.length) URL:result.URL];
                NSInteger resultsOffset = ((NSInteger)decodedString.length) - ((NSInteger)result.range.length);
                for (NSInteger i = 0; i < (NSInteger)updatedResults.count; i++) {
                    if ([updatedResults[i] isKindOfClass:[NSTextCheckingResult class]]) {
                        if (((NSTextCheckingResult *)updatedResults[i]).range.location > result.range.location) {
                            updatedResults[i] = [(NSTextCheckingResult *)updatedResults[i] resultByAdjustingRangesWithOffset:resultsOffset];
                        }
                    } else if ([updatedResults[i] isKindOfClass:[TGTextCheckingResult class]]) {
                        TGTextCheckingResult *current = updatedResults[i];
                        if (current.range.location > result.range.location) {
                            updatedResults[i] = [[TGTextCheckingResult alloc] initWithRange:NSMakeRange(current.range.location + resultsOffset, current.range.length) type:current.type contents:current.contents];
                        }
                    }
                }
            }
            
            *updatedTextCheckingResults = updatedResults;
            
            return updatedString;
        }
    }
    return text;
}

- (instancetype)initWithMessage:(TGMessage *)message hasGame:(bool)hasGame hasInvoice:(bool)hasInvoice authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer viaUser:viaUser context:context];
    if (self != nil)
    {
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
                      });
        _isGame = hasGame;
        _isInvoice = hasInvoice;
        NSArray *textCheckingResults = nil;
        if (hasGame) {
            _text = @"";
            textCheckingResults = nil;
        } else {
            textCheckingResults = message.textCheckingResults;
            NSArray *updatedTextCheckingResults = nil;
            _text = expandedTextAndAttributes(message.text, textCheckingResults, &updatedTextCheckingResults);
            if (updatedTextCheckingResults != nil) {
                textCheckingResults = updatedTextCheckingResults;
            }
        }
        
        CTFontRef font = textFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize);
        /*NSUInteger length = 0;
         if (_text.length < 20 && [TGStringUtils stringContainsEmojiOnly:_text length:&length]) {
         if (length <= 6) {
         font = emojiFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize);
         _emojiOnly = true;
         }
         }*/
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:_text font:font];
        _textModel.textCheckingResults = _isGame ? nil : textCheckingResults;
        _textModel.textColor = [assetsSource messageTextColor];
        if (message.isBroadcast)
            _textModel.additionalTrailingWidth += 10.0f;
        [_contentModel addSubmodel:_textModel];
        
        if ([authorPeer isKindOfClass:[TGUser class]]) {
            TGUser *author = authorPeer;
            _isBot = author.kind == TGUserKindBot || author.kind == TGUserKindSmartBot;
        }
    }
    return self;
}

- (void)refreshMetrics
{
    [_textModel setFont:textFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize)];
}

- (void)updateSearchText:(bool)animated
{
    [self updateSearchHighlight:animated];
}

- (void)setIsUnsupported:(bool)isUnsupported
{
    if (isUnsupported)
    {
        _textModel.text = TGLocalized(@"Conversation.UnsupportedMedia");
        NSRange range = [_textModel.text rangeOfString:@"http://telegram.org/update"];
        if (range.location != NSNotFound)
        {
            _textModel.textCheckingResults = @[[NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:@"http://telegram.org/update"]]];
        }
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    [self updateSearchHighlight:false];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [self clearLinkSelection];
    [self clearSearchHighlights:false];
    
    [super unbindView:viewStorage];
}

- (NSString *)linkAtPoint:(CGPoint)point {
    point.x -= _contentModel.frame.origin.x;
    point.y -= _contentModel.frame.origin.y;
    return [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL];
}

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
                        } else if (_webPage.instantPage != nil && webpageAction != TGWebpageFooterModelActionDownload) {
                            activateInstantPage = true;
                        } else if (_webPage.document.isRoundVideo && webpageAction != TGWebpageFooterModelActionDownload) {
                            activateRoundMessage = true;
                        } else {
                            if ([_webPage.pageType isEqualToString:@"photo"] || [_webPage.pageType isEqualToString:@"article"])
                            {
                                webPage = _webPage;
                            }
                            
                            bool isInstagram = [_webPage.siteName.lowercaseString isEqualToString:@"instagram"];
                            bool isCoub = [_webPage.siteName.lowercaseString isEqualToString:@"coub"];
                            
                            activateWebpageContents = _webPage.embedUrl.length != 0;
                            if (webpageAction == TGWebpageFooterModelActionDownload || webpageAction == TGWebpageFooterModelActionCancel) {
                            } else if (_webPageFooterModel.mediaIsAvailable) {
                                if (webpageIsVideo && !isInstagram) {
                                    activateVideo = true;
                                }
                            }
                            
                            if (isInstagram)
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
            if (_webPage.instantPage != nil && ([linkCandidate hasPrefix:@"http://telegra.ph/"] || [linkCandidate hasPrefix:@"https://telegra.ph/"] || [linkCandidate hasPrefix:@"http://t.me/iv?"] || [linkCandidate hasPrefix:@"https://t.me/iv?"]) && webpageAction != TGWebpageFooterModelActionDownload) {
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
                    [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            }
            else if (recognizer.doubleTapped) {
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            } else if (activateRoundMessage) {
                [_webPageFooterModel activateMediaPlayback];
            } else if (activateVideo) {
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
            } else if (activateGame) {
                [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": [NSString stringWithFormat:@"activate-app://%d", _mid]}];
            } else if (activateInvoice) {
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
            } else if (activateInstantPage) {
                [self instantPageButtonPressed];
            } else if (webpageAction == TGWebpageFooterModelActionDownload) {
                [_context.companionHandle requestAction:@"mediaDownloadRequested" options:@{@"mid": @(_mid)}];
            } else if (webpageAction == TGWebpageFooterModelActionCancel) {
                [_context.companionHandle requestAction:@"mediaProgressCancelRequested" options:@{@"mid": @(_mid)}];
            } else if (webpageAction == TGWebpageFooterModelActionPlay) {
                [_webPageFooterModel activateWebpageContents];
            } else if (webpageAction == TGWebpageFooterModelActionOpenMedia) {
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
            }
            else if (webpageAction == TGWebpageFooterModelActionCustom) {
                [_webPageFooterModel activateWebpageContents];
            } else if (webpageAction == TGWebpageFooterModelActionOpenURL && linkCandidate != nil) {
                [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": linkCandidate, @"mid": @(_mid)}];
            }
            else if (activateWebpageContents)
                [_context.companionHandle requestAction:@"openEmbedRequested" options:@{@"webPage": _webPage, @"mid": @(_mid)}];
            else if (webPage != nil)
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
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
        }
    }
}

- (void)instantPageButtonPressed {
    if (_webPage.instantPage != nil) {
        NSString *fragment = nil;
        NSURL *pageUrl = [[NSURL alloc] initWithString:_webPage.url];
        for (id result in _textModel.textCheckingResults) {
            if ([result isKindOfClass:[NSTextCheckingResult class]]) {
                NSTextCheckingResult *urlResult = result;
                if (urlResult.resultType == NSTextCheckingTypeLink) {
                    if (TGObjectCompare(pageUrl.scheme, urlResult.URL.scheme) && TGObjectCompare(pageUrl.host, urlResult.URL.host) && TGObjectCompare(pageUrl.path, urlResult.URL.path) && TGObjectCompare(pageUrl.query, urlResult.URL.query)) {
                        fragment = urlResult.URL.fragment;
                        break;
                    }
                }
            }
        }
        [_context.companionHandle requestAction:@"activateInstantPage" options:@{@"webpage": _webPage, @"mid": @(_mid), @"fragment": fragment == nil ? @"" : fragment}];
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

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (BOOL)gestureRecognizer1:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[TGDoubleTapGestureRecognizer class]]) {
        CGPoint point = [touch locationInView:[_contentModel boundView]];
        
        if (_webPageFooterModel != nil && CGRectContainsPoint(_webPageFooterModel.frame, point))
        {
            if ([_webPageFooterModel webpageActionAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y)] == TGWebpageFooterModelActionCustom) {
                return false;
            }
        }
    }
    return true;
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
    
    return false;
}

- (void)clearLinkSelection
{
    for (UIView *linkView in _currentLinkSelectionViews)
    {
        [linkView removeFromSuperview];
    }
    _currentLinkSelectionViews = nil;
}

- (void)clearSearchHighlights:(bool)animated
{
    if (_currentSearchHighlightViews != nil)
    {
        if (animated)
        {
            NSArray *views = _currentSearchHighlightViews;
            [UIView animateWithDuration:0.3 animations:^
             {
                 for (UIView *view in views)
                 {
                     view.alpha = 0.0f;
                 }
             } completion:^(__unused BOOL finished)
             {
                 for (UIView *view in views)
                 {
                     [view removeFromSuperview];
                 }
             }];
        }
        else
        {
            for (UIView *view in _currentSearchHighlightViews)
            {
                [view removeFromSuperview];
            }
        }
        _currentSearchHighlightViews = nil;
    }
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

- (void)updateSearchHighlight:(bool)animated
{
    if ([_contentModel boundView] != nil)
    {
        [self clearSearchHighlights:animated];
        
        if (_context.searchText != nil && _context.searchText.length != 0)
        {
            static UIImage *highlightImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
                          {
                              highlightImage = [[TGTelegraphConversationMessageAssetsSource instance] messageLinkFull];
                              /*CGFloat radius = 4.0f;
                               UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
                               CGContextRef context = UIGraphicsGetCurrentContext();
                               CGContextSetFillColorWithColor(context, UIColorRGBA(0xffe438, 0.4f).CGColor);
                               CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
                               highlightImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSInteger)radius];
                               UIGraphicsEndImageContext();*/
                          });
            
            //CGPoint offset = CGPointMake(_contentModel.frame.origin.x - _backgroundModel.frame.origin.x, _contentModel.frame.origin.y - _backgroundModel.frame.origin.y);
            
            NSMutableArray *currentSearchHighlightViews = [[NSMutableArray alloc] init];
            
            [_textModel enumerateSearchRegionsForString:_context.searchText withBlock:^(CGRect region)
             {
                 CGPoint regionOffset = CGPointZero;
                 
                 region.size.width = MAX(8.0f, region.size.width - 1.0f);
                 
                 CGRect topRegion = region;
                 CGRect middleRegion = CGRectZero;
                 CGRect bottomRegion = CGRectZero;
                 
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
                         topView.image = highlightImage;
                     else
                         topView.image = highlightImage;
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
                         middleView.image = highlightImage;
                     else
                         middleView.image = highlightImage;
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
                     bottomView.image = highlightImage;
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
                     //partView.frame = CGRectOffset(partView.frame, _textModel.frame.origin.x + [_contentModel boundView].frame.origin.x, _textModel.frame.origin.y + 1 + [_contentModel boundView].frame.origin.y);
                     //[[_contentModel boundView].superview insertSubview:partView belowSubview:[_contentModel boundView]];
                     
                     partView.frame = CGRectOffset(partView.frame, _textModel.frame.origin.x, _textModel.frame.origin.y + 1);
                     partView.layer.zPosition = -1.0f;
                     [[_contentModel boundView] addSubview:partView];
                 }
                 
                 [currentSearchHighlightViews addObjectsFromArray:linkHighlightedViews];
             }];
            
            _currentSearchHighlightViews = currentSearchHighlightViews;
        }
    }
}

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight containerSize:(CGSize)containerSize
{
    CGRect textFrame = _textModel.frame;
    
    textFrame.origin = CGPointMake(1, headerHeight + TGGetMessageViewModelLayoutConstants()->textBubbleTextOffsetTop);
    if (_emojiOnly) {
        textFrame.origin.y -= 11.0f;
        if (_centerText) {
            textFrame.origin.x = CGFloor((containerSize.width - textFrame.size.width) / 2.0f);
        }
    }
    _textModel.frame = textFrame;
    
    if ([_contentModel needsSubmodelContentsUpdate])
        [self updateSearchHighlight:false];
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)infoWidth
{
    int layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    
    if (_context.commandsEnabled || _isBot)
        layoutFlags |= TGReusableLabelLayoutHighlightCommands;
    
    CGFloat effectiveInfoWidth = infoWidth;
    if (_emojiOnly) {
        effectiveInfoWidth = 0.0f;
    }
    bool updateContents = [_textModel layoutNeedsUpdatingForContainerSize:containerSize additionalTrailingWidth:effectiveInfoWidth layoutFlags:layoutFlags];
    _textModel.layoutFlags = layoutFlags;
    _textModel.additionalTrailingWidth = effectiveInfoWidth;
    if (updateContents)
        [_textModel layoutForContainerSize:containerSize];
    
    if (needsContentsUpdate != NULL && updateContents)
        *needsContentsUpdate = updateContents;
    
    CGSize size = _textModel.frame.size;
    if (_emojiOnly) {
        size.height += 9.0f - 11.0f;
        if (size.width < infoWidth - 5.0f) {
            _centerText = true;
            size.width = infoWidth - 5.0f;
        }
    }
    
    size.width = MAX(size.width, infoWidth - 5.0f);
    
    if (_isGame || _isInvoice || (_text.length == 0 && _webPage != nil)) {
        size.height = 0.0f;
    }
    
    return size;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated {
    NSUInteger previousEntitiesCount = _textModel.textCheckingResults.count;
    
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
    
    bool hasGame = false;
    bool hasInvoice = false;
    NSArray *updatedTextCheckingResults = message.textCheckingResults;
    NSArray *updatedExpandedTextCheckingResults = nil;
    NSString *updatedText = expandedTextAndAttributes(message.text, message.textCheckingResults, &updatedExpandedTextCheckingResults);
    if (updatedExpandedTextCheckingResults != nil) {
        updatedTextCheckingResults = updatedExpandedTextCheckingResults;
    }
    
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
            updatedText = @"";
            updatedTextCheckingResults = nil;
            hasGame = true;
            break;
        } else if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
            hasInvoice = true;
        }
    }
    
    bool forceUpdateText = false;
    if (previousEntitiesCount != updatedTextCheckingResults.count) {
        forceUpdateText = true;
    }
    
    if (!TGStringCompare(updatedText, _text) || forceUpdateText || _isGame != hasGame || _isInvoice != hasInvoice) {
        _text = updatedText;
        _isGame = hasGame;
        _isInvoice = hasInvoice;
        _textModel.text = @"";
        _textModel.text = _text;
        _textModel.textCheckingResults = updatedTextCheckingResults;
        [_contentModel setNeedsSubmodelContentsUpdate];
        *sizeUpdated = true;
    }
}

- (bool)isPreviewableAtPoint:(CGPoint)point {
    point = CGPointMake(point.x - _contentModel.frame.origin.x, point.y - _contentModel.frame.origin.y);
    if (_webPageFooterModel != nil && CGRectContainsPoint(_webPageFooterModel.frame, point))
        return [_webPageFooterModel isPreviewableAtPoint:point];
    
    return false;
}

@end
