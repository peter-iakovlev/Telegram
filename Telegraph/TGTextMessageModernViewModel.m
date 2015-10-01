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

@interface TGTextMessageModernViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate>
{
    TGModernTextViewModel *_textModel;
    bool _textIsRTL;
    
    NSArray *_currentLinkSelectionViews;
    bool _isBot;
    
    NSArray *_currentSearchHighlightViews;
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

- (instancetype)initWithMessage:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context
{
    self = [super initWithMessage:message authorPeer:authorPeer context:context];
    if (self != nil)
    {
        static TGTelegraphConversationMessageAssetsSource *assetsSource = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            assetsSource = [TGTelegraphConversationMessageAssetsSource instance];
        });
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:message.text font:textFontForSize(TGGetMessageViewModelLayoutConstants()->textFontSize)];
        _textModel.textCheckingResults = message.textCheckingResults;
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
            NSString *linkCandidate = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL];
            TGWebPageMediaAttachment *webPage = nil;
            bool activateWebpageContents = false;
            if (linkCandidate == nil)
            {
                if (_webPageFooterModel != nil)
                {
                    if ([_webPageFooterModel hasWebpageActionAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y)])
                    {
                        if ([_webPage.pageType isEqualToString:@"photo"] || [_webPage.pageType isEqualToString:@"article"])
                        {
                            webPage = _webPage;   
                        }
                        activateWebpageContents = _webPage.embedUrl.length != 0;
                        linkCandidate = _webPage.url;
                    }
                    else
                    {
                        linkCandidate = [_webPageFooterModel linkAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y) regionData:NULL];
                    }
                }
            }
            
            if (recognizer.longTapped)
            {
                if (linkCandidate != nil)
                    [_context.companionHandle requestAction:@"openLinkWithOptionsRequested" options:@{@"url": linkCandidate}];
                else
                    [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            }
            else if (recognizer.doubleTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (activateWebpageContents)
                [_context.companionHandle requestAction:@"openEmbedRequested" options:@{@"webPage": _webPage}];
            else if (webPage != nil)
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
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
        }
    }
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)point
{
    [self updateLinkSelection:point];
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

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)point
{
    point = [recognizer locationInView:[_contentModel boundView]];
    
    if ([_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL] != nil ||
        (_forwardedHeaderModel && CGRectContainsPoint(_forwardedHeaderModel.frame, point)) || (_replyHeaderModel && CGRectContainsPoint(_replyHeaderModel.frame, point)))
        return 3;
    
    if (_webPageFooterModel != nil && CGRectContainsPoint(_webPageFooterModel.frame, point))
    {
        if ([_webPageFooterModel hasWebpageActionAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y)])
        {
            return 3;
        }
        
        if ([_webPageFooterModel linkAtPoint:CGPointMake(point.x - _webPageFooterModel.frame.origin.x, point.y - _webPageFooterModel.frame.origin.y) regionData:NULL] != nil)
        {
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

- (void)layoutContentForHeaderHeight:(CGFloat)headerHeight
{
    CGRect textFrame = _textModel.frame;
    
    textFrame.origin = CGPointMake(1, headerHeight + TGGetMessageViewModelLayoutConstants()->textBubbleTextOffsetTop);
    _textModel.frame = textFrame;
    
    if ([_contentModel needsSubmodelContentsUpdate])
        [self updateSearchHighlight:false];
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate hasDate:(bool)hasDate hasViews:(bool)hasViews
{
    int layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
    if (hasDate)
    {
        layoutFlags |= TGReusableLabelLayoutDateSpacing | (_incoming ? 0 : TGReusableLabelLayoutExtendedDateSpacing);
    }
    if (hasViews) {
        layoutFlags |= TGReusableLabelViewCountSpacing;
    }
    
    if (_context.commandsEnabled || _isBot)
        layoutFlags |= TGReusableLabelLayoutHighlightCommands;
    
    bool updateContents = [_textModel layoutNeedsUpdatingForContainerSize:containerSize layoutFlags:layoutFlags];
    _textModel.layoutFlags = layoutFlags;
    if (updateContents)
        [_textModel layoutForContainerSize:containerSize];
    
    if (needsContentsUpdate != NULL)
        *needsContentsUpdate = updateContents;
    
    return _textModel.frame.size;
}

@end
