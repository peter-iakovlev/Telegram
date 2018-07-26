#import "TGUserInfoTextCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernTextViewModel.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

#import <LegacyComponents/ActionStage.h>
#import "TGTelegraph.h"

#import "TGPresentation.h"

@interface TGUserInfoTextCollectionItemViewTextView : UIButton {
    NSArray *_currentLinkSelectionViews;
    NSString *_currentLink;
    
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
}

@property (nonatomic, copy) void (^followLink)(NSString *);
@property (nonatomic, copy) void (^holdLink)(NSString *);
@property (nonatomic, readonly) bool trackingLink;
@property (nonatomic, strong) TGModernTextViewModel *textModel;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, strong) UIColor *linkHighlightColor;

@end

@implementation TGUserInfoTextCollectionItemViewTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.opaque = false;
        self.backgroundColor = [UIColor clearColor];
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }
    return self;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _trackingLink = false;
        
        if (_holdLink) {
            _holdLink(_currentLink);
        }
    }
}

- (void)setTextModel:(TGModernTextViewModel *)textModel {
    _textModel = textModel;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)__unused rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_textModel drawInContext:context];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)__unused event {
    if ([_textModel linkAtPoint:point regionData:NULL] != nil) {
        return self;
    }
    
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _trackingLink = true;
    
    [self updateLinkSelection:[[touches anyObject] locationInView:self]];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    _trackingLink = false;
    [self clearLinkSelection];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self clearLinkSelection];
    if (_trackingLink) {
        _trackingLink = false;
        
        if (_currentLink.length != 0) {
            [self followLink:_currentLink];
        }
    }
}

- (void)followLink:(NSString *)link {
    if (_followLink) {
        _followLink(link);
    }
}

- (void)holdLink:(NSString *)link {
    if (_holdLink) {
        _holdLink(link);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)clearLinkSelection {
    for (UIView *view in _currentLinkSelectionViews) {
        [view removeFromSuperview];
    }
    _currentLinkSelectionViews = nil;
}

- (void)updateLinkSelection:(CGPoint)point
{
    [self clearLinkSelection];
    
    CGPoint offset = CGPointZero;
    
    NSArray *regionData = nil;
    NSString *link = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x - offset.x, point.y - _textModel.frame.origin.y - offset.y) regionData:&regionData];
    
    CGPoint regionOffset = CGPointZero;
    
    if (link != nil)
    {
        _currentLink = link;
        
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
            [self addSubview:partView];
        }
        
        _currentLinkSelectionViews = linkHighlightedViews;
    }
}

@end

@interface TGUserInfoTextCollectionItemView ()
{
    UIView *_separatorView;
    
    UILabel *_labelView;
    TGUserInfoTextCollectionItemViewTextView *_textContentView;
    
    TGCheckButtonView *_checkView;
}

@end

@implementation TGUserInfoTextCollectionItemView

+ (UIFont *)font
{
    return TGSystemFontOfSize(17.0f);
}

+ (CGFloat)heightForWidth:(CGFloat)__unused width textModel:(TGModernTextViewModel *)textModel
{
    CGSize textSize = textModel.frame.size;
    
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    return textSize.height + 41.0f;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.selectionInsets = UIEdgeInsetsMake(TGScreenPixel, 0.0f, 0.0f, 0.0f);
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self.backgroundView addSubview:_separatorView];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = TGAccentColor();
        _labelView.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_labelView];
        
        _textContentView = [[TGUserInfoTextCollectionItemViewTextView alloc] init];
        _textContentView.userInteractionEnabled = true;
        [self.contentView addSubview:_textContentView];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _labelView.textColor = presentation.pallete.collectionMenuTextColor;
    _separatorView.backgroundColor = presentation.pallete.collectionMenuSeparatorColor;
    _textContentView.linkColor = presentation.pallete.linkColor;
}

- (void)setChecking:(bool)checking
{
    if (_checkView == nil)
    {
        _checkView = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleDefaultBlue pallete:self.presentation.checkButtonPallete];
        _checkView.userInteractionEnabled = false;
        [self addSubview:_checkView];
    }
    _checkView.hidden = !checking;
    [self setNeedsLayout];
}

- (void)setIsChecked:(bool)checked animated:(bool)animated
{
    [_checkView setSelected:checked animated:animated];
}

- (void)setTitle:(NSString *)title
{
    _labelView.text = title;
    [self setNeedsLayout];
}

- (void)setTextModel:(TGModernTextViewModel *)textModel
{
    _textContentView.textModel = textModel;
    [self setNeedsLayout];
}

- (bool)shouldDisplayContextMenu {
    return ![_textContentView trackingLink];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    bool hasCheck = _checkView != nil && !_checkView.hidden;
    
    _checkView.frame = CGRectMake(14.0f + self.safeAreaInset.left, TGScreenPixelFloor((self.frame.size.height - _checkView.frame.size.height) / 2.0f), _checkView.frame.size.width, _checkView.frame.size.height);
    
    CGFloat separatorHeight = TGScreenPixel;
    CGFloat separatorInset = (hasCheck ? 60.0f : 15.0f) + self.safeAreaInset.left;
    _separatorView.frame = CGRectMake(separatorInset, bounds.size.height - separatorHeight, bounds.size.width - separatorInset, separatorHeight);
    
    CGFloat leftPadding = (hasCheck ? 60.0f : 15.0f) + TGScreenPixel + self.safeAreaInset.left;
    
    CGSize labelSize = [_labelView.text sizeWithFont:_labelView.font constrainedToSize:CGSizeMake(bounds.size.width - leftPadding - self.safeAreaInset.right - 10.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    labelSize.width = CGCeil(labelSize.width);
    labelSize.height = CGCeil(labelSize.height);
    _labelView.frame = CGRectMake(leftPadding, 11.0f, labelSize.width, labelSize.height);
    
    CGRect frame = CGRectMake((hasCheck ? 60.0f : 15.0f) + self.safeAreaInset.left, CGFloor(labelSize.height + 1.0f) + 8.0f, _textContentView.textModel.frame.size.width, _textContentView.textModel.frame.size.height);
    
    if (!CGSizeEqualToSize(_textContentView.frame.size, frame.size) || !CGPointEqualToPoint(_textContentView.frame.origin, frame.origin))
    {
        _textContentView.frame = frame;
        [_textContentView setNeedsDisplay];
    }
}

- (void)setFollowLink:(void (^)(NSString *))followLink {
    _textContentView.followLink = followLink;
}

- (void)setHoldLink:(void (^)(NSString *))holdLink {
    _textContentView.holdLink = holdLink;
}

@end
