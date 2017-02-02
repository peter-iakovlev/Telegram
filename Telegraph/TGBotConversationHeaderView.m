#import "TGBotConversationHeaderView.h"

#import "TGTextMessageBackgroundViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGReusableLabel.h"
#import "TGModernFlatteningViewModel.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGViewController.h"

#import "TGMessage.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

#import "TGDoubleTapGestureRecognizer.h"

@interface TGBotConversationHeaderView () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate>
{
    TGModernViewContext *_context;
    TGModernViewStorage *_viewStorage;
    TGTextMessageBackgroundViewModel *_backgroundModel;
    UILabel *_titleLabel;
    TGModernFlatteningViewModel *_contentModel;
    TGModernTextViewModel *_textModel;
    NSMutableArray *_currentLinkSelectionViews;
    UIButton *_startButton;
    
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
}

@end

@implementation TGBotConversationHeaderView

- (instancetype)initWithContext:(TGModernViewContext *)context botInfo:(TGBotInfo *)botInfo
{
    self = [super init];
    if (self != nil)
    {
        _context = context;
        _viewStorage = [[TGModernViewStorage alloc] init];
        
        _backgroundModel = [[TGTextMessageBackgroundViewModel alloc] initWithType:TGTextMessageBackgroundIncoming];
        [_backgroundModel setPartialMode:true];
        [_backgroundModel bindViewToContainer:self viewStorage:_viewStorage];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = botInfo.botDescription;
        _titleLabel.text = TGLocalized(@"Bot.DescriptionTitle");
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [self addSubview:_titleLabel];
        
        NSString *text = botInfo.botDescription;
        
        _contentModel = [[TGModernFlatteningViewModel alloc] initWithContext:nil];
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:text font:TGCoreTextSystemFontOfSize(16.0f)];
        _textModel.textCheckingResults = [TGMessage textCheckingResultsForText:text highlightMentionsAndTags:true highlightCommands:true entities:nil];
        _textModel.layoutFlags = TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightCommands | TGReusableLabelLayoutHighlightLinks;
        [_textModel layoutForContainerSize:CGSizeMake([self maximumContentWidth], CGFLOAT_MAX)];
        [_contentModel addSubmodel:_textModel];
        
        [_contentModel bindViewToContainer:self viewStorage:_viewStorage];
        [_contentModel setNeedsSubmodelContentsUpdate];
        
        _currentLinkSelectionViews = [[NSMutableArray alloc] init];
        
        _boundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(messageDoubleTapGesture:)];
        _boundDoubleTapRecognizer.delegate = self;
        [_contentModel.boundView addGestureRecognizer:_boundDoubleTapRecognizer];
    }
    return self;
}

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer shouldFailTap:(CGPoint)point
{
    if ([_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL] != nil)
    {
        return 3;
    }
    
    return false;
}

- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)__unused recognizer didBeginAtPoint:(CGPoint)point
{
    [self updateLinkSelection:point];
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
            
            if (linkCandidate != nil)
            {
                if (recognizer.longTapped)
                {
                    [_context.companionHandle requestAction:@"openLinkWithOptionsRequested" options:@{@"url": linkCandidate}];
                }
                else
                {
                    [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": linkCandidate}];
                }
            }
        }
    }
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
        
        CGPoint offset = CGPointZero;// CGPointMake(_contentModel.frame.origin.x - _backgroundModel.frame.origin.x, _contentModel.frame.origin.y - _backgroundModel.frame.origin.y);
        
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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (CGFloat)titleSpacing
{
    return 7.0f;
}

- (CGFloat)maximumContentWidth
{
    UIEdgeInsets backgroundInsets = [self backgroundInsets];
    UIEdgeInsets contentInsets = [self contentInsets];
    
    CGFloat minSide = MIN([TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait].width, [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait].height);
    if (TGIsPad())
        minSide = 448.0f;
    
    return CGFloor(minSide * 0.85f - backgroundInsets.left - backgroundInsets.right - contentInsets.left - contentInsets.right);
}

- (void)sizeToFit
{
    UIEdgeInsets backgroundInsets = [self backgroundInsets];
    UIEdgeInsets contentInsets = [self contentInsets];
    
    CGFloat maxWidth = [self maximumContentWidth];
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(maxWidth, FLT_MAX)];
    titleSize.width = CGCeil(titleSize.width);
    titleSize.height = CGCeil(titleSize.height);
    
    CGSize labelSize = _textModel.frame.size;
    
    CGFloat contentWidth = MAX(labelSize.width, titleSize.width);
    
    _titleLabel.frame = CGRectMake(backgroundInsets.left + contentInsets.left + CGFloor((contentWidth - titleSize.width) / 2.0f), backgroundInsets.top + contentInsets.top, titleSize.width, titleSize.height);
    
    _contentModel.frame = CGRectMake(backgroundInsets.left + contentInsets.left - 2, backgroundInsets.top + contentInsets.top + titleSize.height + [self titleSpacing] - 2, contentWidth + 4, labelSize.height + 4);
    [_contentModel updateSubmodelContentsIfNeeded];
    
    _textModel.frame = CGRectMake(2.0f, 2.0f, _textModel.frame.size.width, _textModel.frame.size.height);
    
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, MAX(labelSize.width, titleSize.width) + backgroundInsets.left +  backgroundInsets.right + contentInsets.left + contentInsets.right, labelSize.height + backgroundInsets.top + backgroundInsets.bottom + contentInsets.top + contentInsets.bottom + titleSize.height + [self titleSpacing]);
    
    if (false && [TGViewController hasLargeScreen])
    {
        frame.size.width = CGEven(frame.size.width);
        frame.size.height = CGEven(frame.size.height);
    }
    else
    {
        frame.size.width = CGOdd(frame.size.width);
        frame.size.height = CGOdd(frame.size.height);
    }
    
    self.frame = frame;
}

- (UIEdgeInsets)backgroundInsets
{
    return UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, 0.0f);
}

- (UIEdgeInsets)contentInsets
{
    return UIEdgeInsetsMake(12.0f, 20.0f, 12.0f, 20.0f);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    UIEdgeInsets backgroundInsets = [self backgroundInsets];
    _backgroundModel.frame = CGRectMake(backgroundInsets.left - 3.0f, backgroundInsets.top, bounds.size.width - backgroundInsets.left + backgroundInsets.right, bounds.size.height - backgroundInsets.top - backgroundInsets.bottom);
}

@end
