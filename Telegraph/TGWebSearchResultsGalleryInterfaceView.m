#import "TGWebSearchResultsGalleryInterfaceView.h"

#import "TGModernButton.h"
#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGImagePickerCheckButton.h"

@interface TGWebSearchResultsGalleryInterfaceView ()
{
    void (^_closePressed)();
    
    UIView *_toolbarView;
    TGModernButton *_cancelButton;
    TGModernButton *_doneButton;
    UIImageView *_countBadge;
    UILabel *_countLabel;
    TGImagePickerCheckButton *_checkButton;
    id<TGModernGalleryItem> _currentItem;
    
    SMetaDisposable *_currentItemViewAvailabilityDisposable;
}

@end

@implementation TGWebSearchResultsGalleryInterfaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _toolbarView = [[UIView alloc] init];
        [self addSubview:_toolbarView];
        
        UIImageView *darkBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImagePickerPreviewPanel.png"]];
        darkBackground.frame = _toolbarView.bounds;
        darkBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_toolbarView addSubview:darkBackground];
        _toolbarView.backgroundColor = UIColorRGBA(0x000000, 0.7f);
        
        _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _cancelButton.exclusiveTouch = true;
        [_cancelButton setTitle:TGLocalized(@"Common.Back") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor]];
        _cancelButton.titleLabel.font = TGSystemFontOfSize(17);
        _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_cancelButton sizeToFit];
        _cancelButton.frame = CGRectMake(0, 0, MAX(60.0f, _cancelButton.frame.size.width), 44);
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView addSubview:_cancelButton];
        
        _doneButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        _doneButton.exclusiveTouch = true;
        [_doneButton setTitle:TGLocalized(@"MediaPicker.Send") forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor]];
        _doneButton.titleLabel.font = TGMediumSystemFontOfSize(17);
        _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 27, 0, 10);
        [_doneButton sizeToFit];
        CGFloat darkDoneButtonWidth = MAX(40.0f, _doneButton.frame.size.width);
        _doneButton.frame = CGRectMake(_toolbarView.frame.size.width - darkDoneButtonWidth, 0, darkDoneButtonWidth, 44);
        _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_toolbarView addSubview:_doneButton];
        
        static UIImage *darkCountBadgeBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(22.0f, 22.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetFillColorWithColor(context, UIColorRGB(0x14c944).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 22.0f, 22.0f));
                darkCountBadgeBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:11.0f topCapHeight:11.0f];
                UIGraphicsEndImageContext();
            }
        });
        
        _countBadge = [[UIImageView alloc] initWithImage:darkCountBadgeBackground];
        _countBadge.alpha = 0.0f;
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = TGLightSystemFontOfSize(14);
        [_countBadge addSubview:_countLabel];
        [_doneButton addSubview:_countBadge];
        
        _checkButton = [[TGImagePickerCheckButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 56, 7, 49, 49)];
        _checkButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_checkButton setChecked:false animated:false];
        [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkButton];
        
        
    }
    return self;
}

- (bool)allowsDismissalWithSwipeGesture
{
    return true;
}

- (void)setClosePressed:(void (^)())closePressed
{
    _closePressed = [closePressed copy];
}

- (void)itemFocused:(id<TGModernGalleryItem>)item itemView:(TGModernGalleryItemView *)__unused itemView
{
    _currentItem = item;
    [_checkButton setChecked:_isItemSelected && _isItemSelected(item) animated:false];
    
    if (_currentItemViewAvailabilityDisposable == nil)
        _currentItemViewAvailabilityDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGWebSearchResultsGalleryInterfaceView *weakSelf = self;
    [_currentItemViewAvailabilityDisposable setDisposable:[[itemView contentAvailabilityStateSignal] startWithNext:^(id next)
    {
        __strong TGWebSearchResultsGalleryInterfaceView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            bool available = [next boolValue];
            TGLog(@"available: %d", (int)available);
        }
    }]];
}

- (void)checkButtonPressed
{
    if (_currentItem != nil)
    {
        if (_itemSelected)
            _itemSelected(_currentItem);
        [_checkButton setChecked:_isItemSelected && _isItemSelected(_currentItem) animated:true];
    }
}

- (void)cancelButtonPressed
{
    if (_closePressed)
        _closePressed();
}

- (void)doneButtonPressed
{
    if (_donePressed)
        _donePressed(_currentItem);
}

- (void)updateSelectionInterface:(NSUInteger)selectedCount animated:(bool)animated
{
    bool incremented = true;
    
    float badgeAlpha = 0.0f;
    if (selectedCount != 0)
    {
        badgeAlpha = 1.0f;
        
        if (_countLabel.text.length != 0)
            incremented = [_countLabel.text intValue] < (int)selectedCount;
        
        _countLabel.text = [[NSString alloc] initWithFormat:@"%d", (int)selectedCount];
        [_countLabel sizeToFit];
    }
    
    CGFloat badgeWidth = MAX(22.0f, _countLabel.frame.size.width + 14.0f);
    _countBadge.transform = CGAffineTransformIdentity;
    _countBadge.frame = CGRectMake(-badgeWidth + 22, 10 + TGRetinaPixel, badgeWidth, 22);
    _countLabel.frame = CGRectMake(TGRetinaFloor((badgeWidth - _countLabel.frame.size.width) / 2), 2 + TGRetinaPixel, _countLabel.frame.size.width, _countLabel.frame.size.height);
    
    if (animated)
    {
        if (_countBadge.alpha < FLT_EPSILON && badgeAlpha > FLT_EPSILON)
        {
            _countBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.alpha = badgeAlpha;
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
        else if (_countBadge.alpha > FLT_EPSILON && badgeAlpha < FLT_EPSILON)
        {
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.alpha = badgeAlpha;
                _countBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    _countBadge.transform = CGAffineTransformIdentity;
                }
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
        _countBadge.alpha = badgeAlpha;
    }
}

- (void)addItemHeaderView:(UIView *)__unused itemHeaderView
{
    
}

- (void)removeItemHeaderView:(UIView *)__unused itemHeaderView
{
    
}

- (void)addItemFooterView:(UIView *)__unused itemFooterView
{
    
}

- (void)removeItemFooterView:(UIView *)__unused itemFooterView
{
    
}

- (void)addItemLeftAcessoryView:(UIView *)__unused itemLeftAcessoryView
{
    
}

- (void)removeItemLeftAcessoryView:(UIView *)__unused itemLeftAcessoryView
{
    
}

- (void)addItemRightAcessoryView:(UIView *)__unused itemRightAcessoryView
{
    
}

- (void)removeItemRightAcessoryView:(UIView *)__unused itemRightAcessoryView
{
    
}

- (void)animateTransitionInWithDuration:(NSTimeInterval)__unused dutation
{
    
}

- (void)animateTransitionOutWithDuration:(NSTimeInterval)__unused dutation
{
    
}

- (void)setTransitionOutProgress:(CGFloat)__unused transitionOutProgress
{
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isDescendantOfView:_toolbarView] || view == _checkButton)
        return view;
    
    return nil;
}

- (bool)prefersStatusBarHidden
{
    return !_showStatusBar;
}

- (bool)allowsHide
{
    return false;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _toolbarView.frame = CGRectMake(0.0f, self.frame.size.height - 44.0f, self.frame.size.width, 44.0f);
}

@end
