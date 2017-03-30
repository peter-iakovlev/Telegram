#import "TGShareSendButtonItemView.h"
#import "TGMenuSheetButtonItemView.h"
#import "TGShareCommentView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGModernButton.h"

@interface TGShareSendButtonItemView ()
{
    TGMenuSheetButtonItemView *_actionButton;
    TGModernButton *_sendButton;
    UIImageView *_countBadge;
    UILabel *_countLabel;
    
    TGShareCommentView *_commentView;
    CGFloat _textHeight;
    
    NSInteger _selectedCount;
    void (^_sendAction)(NSString *);
}
@end

@implementation TGShareSendButtonItemView

@dynamic didBeginEditingComment;

- (instancetype)initWithActionTitle:(NSString *)actionTitle action:(void (^)(void))action sendAction:(void (^)(NSString *caption))sendAction
{
    self = [self initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        self.clipsToBounds = true;
        
        _sendAction = sendAction;
        
        if (actionTitle.length > 0)
        {
            _actionButton = [[TGMenuSheetButtonItemView alloc] initWithTitle:actionTitle type:TGMenuSheetButtonTypeDefault action:^
            {
                action();
            }];
            [self addSubview:_actionButton];
        }
        
        _sendButton = [[TGModernButton alloc] initWithFrame:CGRectZero];
        [_sendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 35)];
        _sendButton.exclusiveTouch = true;
        _sendButton.titleLabel.font = TGMediumSystemFontOfSize(20);
        _sendButton.userInteractionEnabled = false;
        [_sendButton setTitleColor:TGAccentColor()];
        _sendButton.alpha = 0.0f;
        [_sendButton setTitle:TGLocalized(@"ShareMenu.Send") forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
        
        static UIImage *countBadgeBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(22, 22), false, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0, 0, 22, 22));
            countBadgeBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:11 topCapHeight:11];
            UIGraphicsEndImageContext();
        });
        
        _countBadge = [[UIImageView alloc] initWithImage:countBadgeBackground];
        _countBadge.alpha = 0.0f;
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = TGSystemFontOfSize(15);
        [_countBadge addSubview:_countLabel];
        [_sendButton addSubview:_countBadge];
        
        __weak TGShareSendButtonItemView *weakSelf = self;
        _commentView = [[TGShareCommentView alloc] initWithFrame:CGRectZero];
        _commentView.alpha = 0.0f;
        _commentView.userInteractionEnabled = false;
        _commentView.heightChanged = ^(CGFloat height)
        {
            __strong TGShareSendButtonItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_textHeight = height;
            [strongSelf _updateHeightAnimated:true];
        };
        [self addSubview:_commentView];
    }
    return self;
}


- (NSString *)caption
{
    return _commentView.text;
}

- (void)setSelectedBadgeCount:(NSInteger)count animated:(bool)animated
{
    bool incremented = true;
    
    CGFloat alpha = 0.0f;
    if (count != 0)
    {
        alpha = 1.0f;
        
        if (_countLabel.text.length != 0)
            incremented = [_countLabel.text integerValue] < count;
        
        _countLabel.text = [[NSString alloc] initWithFormat:@"%ld", count];
        [_countLabel sizeToFit];
    }
    
    CGFloat badgeWidth = 22;
    CGFloat xOffset = (count == 1) ? -0.5f : 0;
    if (count > 9)
        badgeWidth = MAX(22, _countLabel.frame.size.width + 14);
    _countBadge.transform = CGAffineTransformIdentity;
    _countBadge.frame = CGRectMake(CGRectGetMaxX(_sendButton.titleLabel.frame) + 8.0f, (_sendButton.frame.size.height - 22) / 2.0f, badgeWidth, 22);
    _countLabel.frame = CGRectMake((badgeWidth - _countLabel.frame.size.width) / 2.0f + xOffset, 2, _countLabel.frame.size.width, _countLabel.frame.size.height);
    
    if (animated)
    {
        if (_countBadge.alpha < FLT_EPSILON && alpha > FLT_EPSILON)
        {
            _countBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.alpha = alpha;
                _countBadge.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                    {
                        _countBadge.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }];
        }
        else if (_countBadge.alpha > FLT_EPSILON && alpha < FLT_EPSILON)
        {
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.alpha = alpha;
                _countBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            } completion:^(BOOL finished)
            {
                if (finished)
                    _countBadge.transform = CGAffineTransformIdentity;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.transform = incremented ? CGAffineTransformMakeScale(1.2f, 1.2f) : CGAffineTransformMakeScale(0.8f, 0.8f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                    {
                        _countBadge.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }];
        }
    }
    else
    {
        _countBadge.transform = CGAffineTransformIdentity;
        _countBadge.alpha = alpha;
    }
}

- (void)setDidBeginEditingComment:(void (^)(void))didBeginEditingComment
{
    _commentView.didBeginEditing = [didBeginEditingComment copy];
}

- (void)sendButtonPressed
{
    if (_sendAction != nil)
        _sendAction(self.caption);
}

- (void)dismissCommentView
{
    [_commentView.textView resignFirstResponder];
}

- (void)setSelectedCount:(NSInteger)count
{
    bool wasExpanded = (_selectedCount > 0);
    NSInteger previousCount = _selectedCount;
    _selectedCount = count;
    bool expanded = (_selectedCount > 0);
    bool animated = previousCount > 0;
    
    if (_selectedCount > 0)
    {
        _sendButton.userInteractionEnabled = true;
        _commentView.userInteractionEnabled = true;
        [UIView animateWithDuration:0.15 delay:0.05 options:UIViewAnimationOptionCurveLinear animations:^
        {
            _commentView.alpha = 1.0f;
        } completion:nil];
        [UIView animateWithDuration:0.18 animations:^
        {
            _sendButton.alpha = 1.0f;
        }];
        [_actionButton setHidden:true animated:true];
        
        [self setSelectedBadgeCount:count animated:animated];
    }
    else
    {
        _sendButton.userInteractionEnabled = false;
        [_commentView.textView resignFirstResponder];
        _commentView.userInteractionEnabled = false;
        [UIView animateWithDuration:0.18 animations:^
        {
            _sendButton.alpha = 0.0f;
        }];
        [UIView animateWithDuration:0.15 animations:^
        {
            _commentView.alpha = 0.0f;
        }];
        [_actionButton setHidden:false animated:true];
    }
    
    if (wasExpanded != expanded)
        [self _updateHeightAnimated:true];
}

- (bool)inhibitPan
{
    return _commentView.textView.isFirstResponder;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)screenHeight
{
    if (self.collapsed)
        return 0.0f;
    
    if ((NSInteger)screenHeight == 480)
        _commentView.maxHeight = 60.0f;
    
    CGFloat expandedHeight = MAX(TGMenuSheetButtonItemViewHeight * 2, TGMenuSheetButtonItemViewHeight + _textHeight + 17.0f);
    CGFloat defaultHeight = (_actionButton != nil) ? TGMenuSheetButtonItemViewHeight : 0.0f;
    return (_selectedCount == 0) ? defaultHeight : expandedHeight;
}

- (void)layoutSubviews
{
    _commentView.frame = CGRectMake(16.0f, 16.0f, self.frame.size.width - 16.0f * 2, _commentView.frame.size.height);
    _sendButton.frame = CGRectMake(0.0f, self.frame.size.height - TGMenuSheetButtonItemViewHeight, self.frame.size.width, TGMenuSheetButtonItemViewHeight);
    _actionButton.frame = _sendButton.frame;
}

@end
