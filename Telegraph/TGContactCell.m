#import "TGContactCell.h"

#import "TGLabel.h"
#import "TGRemoteImageView.h"
#import "TGDateLabel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGInterfaceAssets.h"

#import "TGActionTableView.h"

#import "TGContactCellContents.h"

#import "TGLetteredAvatarView.h"

#import <QuartzCore/QuartzCore.h>

static UIImage *contactCellCheckImage()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"ModernContactSelectionEmpty.png"];
    return image;
}

static UIImage *contactCellCheckedImage()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"ModernContactSelectionChecked.png"];
    return image;
}

@interface TGContactCheckButton : UIButton

@property (nonatomic, strong) UIImageView *checkView;

- (void)setChecked:(bool)checked animated:(bool)animated;

@end

@implementation TGContactCheckButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.exclusiveTouch = true;
    
    _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [self addSubview:_checkView];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _checkView.transform = CGAffineTransformIdentity;
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (!CGRectContainsPoint(self.bounds, [touch locationInView:self]))
        _checkView.transform = CGAffineTransformIdentity;
    else
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (!CGRectContainsPoint(self.bounds, [touch locationInView:self]))
        _checkView.transform = CGAffineTransformIdentity;
    else
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    
    [super touchesMoved:touches withEvent:event];
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    _checkView.image = checked ? contactCellCheckedImage() : contactCellCheckImage();
    
    if (animated)
    {
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        if (checked)
        {
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _checkView.transform = CGAffineTransformMakeScale(1.16f, 1.16f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                    {
                        _checkView.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }];
        }
        else
        {
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _checkView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
    else
    {
        _checkView.transform = CGAffineTransformIdentity;
    }
}

@end

@interface TGContactCell ()
{
    CALayer *_separatorLayer;
}

@property (nonatomic, strong) TGLetteredAvatarView *avatarView;
@property (nonatomic, strong) TGDateLabel *subtitleLabel;

@property (nonatomic, strong) TGContactCheckButton *checkButton;

@property (nonatomic, strong) UIView *highlightedBackgroundView;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) TGContactCellContents *contactContentsView;

@end

@implementation TGContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier selectionControls:false editingControls:false];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier selectionControls:(bool)selectionControls editingControls:(bool)__unused editingControls
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.superview.clipsToBounds = false;
        
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.contentView.layer addSublayer:_separatorLayer];
        
        self.backgroundView = nil;
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = TGSelectionColor();
        self.selectedBackgroundView = selectedView;
        
        if (selectionControls)
        {
            UIView *tapAreaView = [[UIView alloc] initWithFrame:self.contentView.bounds];
            tapAreaView.userInteractionEnabled = true;
            tapAreaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.contentView addSubview:tapAreaView];
            
            _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
            _tapRecognizer.cancelsTouchesInView = false;
            [tapAreaView addGestureRecognizer:_tapRecognizer];
        }
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:false];
        _avatarView.fadeTransition = true;
        [self.contentView addSubview:_avatarView];
        
        _contactContentsView = [[TGContactCellContents alloc] initWithFrame:self.contentView.bounds];
        _contactContentsView.userInteractionEnabled = false;
        _contactContentsView.titleFont = TGSystemFontOfSize(17);
        _contactContentsView.titleBoldFont = TGMediumSystemFontOfSize(17.0f);
        _contactContentsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_contactContentsView];
        
        _boldMode = 2;
        
        CGFloat subtitleFontSize = TGIsPad() ? 14.0f : 13.0f;
        CGFloat amWidth = TGIsPad() ? 23.0f : 22.0f;
        
        _subtitleLabel = [[TGDateLabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.contentMode = UIViewContentModeLeft;
        _subtitleLabel.dateFont = TGSystemFontOfSize(subtitleFontSize);
        _subtitleLabel.dateTextFont = _subtitleLabel.dateFont;
        _subtitleLabel.dateLabelFont = TGSystemFontOfSize(subtitleFontSize);
        _subtitleLabel.amWidth = amWidth;
        _subtitleLabel.pmWidth = amWidth;
        _subtitleLabel.dstOffset = 0.0f;
        _subtitleLabel.textColor = UIColorRGB(0x888888);
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        
        _contactContentsView.dateLabel = _subtitleLabel;
        
        if (selectionControls)
        {
            _checkButton = [[TGContactCheckButton alloc] init];
            _checkButton.userInteractionEnabled = true;
            [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_checkButton];
        }
    }
    return self;
}

- (void)setSubtitleText:(NSString *)subtitleText
{
    _subtitleAttributedText = nil;
    _subtitleText = subtitleText;
}

- (void)setSubtitleAttributedText:(NSAttributedString *)subtitleAttributedText
{
    _subtitleAttributedText = subtitleAttributedText;
    _subtitleText = nil;
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self checkButtonPressed];
    }
}

- (void)checkButtonPressed
{
    [_actionHandle requestAction:@"/contactlist/toggleItem" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_itemId], @"itemId", [NSNumber numberWithBool:_contactSelected], @"selected", self, @"cell", nil]];
}

- (void)actionButtonPressed
{
    [_actionHandle requestAction:@"contactCellAction" options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_itemId], @"itemId", nil]];
}

- (void)setBoldMode:(int)index
{
    if (_boldMode != index)
        _boldMode = index;
}

- (void)setIsDisabled:(bool)isDisabled
{
    if (_isDisabled != isDisabled)
    {
        _isDisabled = isDisabled;
        
        _subtitleLabel.isDisabled = isDisabled;
        
        [self setSelectionStyle:isDisabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue];
        _contactContentsView.isDisabled = isDisabled;
        [_contactContentsView setNeedsDisplay];
    }
}

- (void)resetView:(bool)animateState
{
    if (_titleTextSecond == nil || _titleTextSecond.length == 0)
    {
        _contactContentsView.titleBoldMode = 1;
        _contactContentsView.titleFirst = _titleTextFirst;
        _contactContentsView.titleSecond = nil;
    }
    else
    {
        _contactContentsView.titleBoldMode = _boldMode;
        _contactContentsView.titleFirst = _titleTextFirst;
        _contactContentsView.titleSecond = _titleTextSecond;
    }
    if (_subtitleAttributedText != nil)
    {
        _subtitleLabel.attributedText = _subtitleAttributedText;
        [_subtitleLabel measureTextSize];
        
        _subtitleLabel.hidden = _subtitleAttributedText.length == 0;
    }
    else
    {
        _subtitleLabel.dateText = _subtitleText;
        [_subtitleLabel measureTextSize];
        
        _subtitleLabel.hidden = _subtitleText == nil || _subtitleText.length == 0;
    }
    
    if (false && _hideAvatar)
    {
        _avatarView.hidden = true;
    }
    else
    {
        _avatarView.hidden = false;
        
        CGFloat diameter = TGIsPad() ? 45.0f : 40.0f;
        
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            //!placeholder
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
            CGContextSetLineWidth(context, 1.0f);
            CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, diameter - 1.0f, diameter - 1.0f));
            
            placeholder = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        if (_avatarUrl.length != 0)
        {
            _avatarView.fadeTransitionDuration = animateState ? 0.14 : 0.3;
            if (![_avatarUrl isEqualToString:_avatarView.currentUrl])
            {
                if (animateState)
                {
                    UIImage *currentImage = [_avatarView currentImage];
                    [_avatarView loadImage:_avatarUrl filter:TGIsPad() ? @"circle:45x45" : @"circle:40x40" placeholder:(currentImage != nil ? currentImage : placeholder) forceFade:true];
                }
                else
                    [_avatarView loadImage:_avatarUrl filter:TGIsPad() ? @"circle:45x45" : @"circle:40x40" placeholder:placeholder];
            }
        }
        else
        {
            [_avatarView loadUserPlaceholderWithSize:CGSizeMake(diameter, diameter) uid:_hideAvatar ? 0 : (int32_t)_itemId firstName:_user.firstName lastName:_user.lastName placeholder:placeholder];
        }
    }
    
    if (_checkButton != nil)
        [self updateFlags:_contactSelected];
    
    if (!_subtitleLabel.hidden)
    {
        static UIColor *normalColor = nil;
        static UIColor *activeColor = nil;
        if (normalColor == nil)
        {
            normalColor = UIColorRGB(0xa6a6a6);
            activeColor = TGAccentColor();
        }
        _subtitleLabel.textColor = _subtitleActive ? activeColor : normalColor;
        [_contactContentsView setNeedsDisplay];
    }
    
    [self setNeedsLayout];
    [_contactContentsView setNeedsDisplay];
}

- (void)updateFlags:(bool)contactSelected
{
    [self updateFlags:contactSelected force:false];
}

- (void)updateFlags:(bool)contactSelected force:(bool)force
{
    [self updateFlags:contactSelected animated:true force:force];
}

- (void)updateFlags:(bool)contactSelected animated:(bool)animated force:(bool)force
{
    if (_contactSelected != contactSelected || force)
    {
        _contactSelected = contactSelected;
        [_checkButton setChecked:_contactSelected animated:animated];
    }
}

- (void)setSelectionEnabled:(bool)selectionEnabled animated:(bool)animated
{
    if (_selectionEnabled != selectionEnabled)
    {
        _selectionEnabled = selectionEnabled;
        
        if (_selectionEnabled)
        {
            _checkButton.hidden = false;
            
            [_checkButton setChecked:_contactSelected animated:false];
            
            if (animated)
            {
                [UIView animateWithDuration:0.3 animations:^
                {
                    _checkButton.alpha = 1.0f;
                    [self layoutSubviews];
                }];
            }
            else
            {
                _checkButton.alpha = 1.0f;
                [self layoutSubviews];
            }
        }
        else if (_checkButton != nil)
        {
            if (animated)
            {
                [UIView animateWithDuration:0.3 animations:^
                {
                    _checkButton.alpha = 0.0f;
                    [self layoutSubviews];
                } completion:^(BOOL finished)
                {
                    if (finished)
                    {
                        _checkButton.hidden = true;
                    }
                }];
            }
            else
            {
                _checkButton.alpha = 0.0f;
                _checkButton.hidden = true;
                [self layoutSubviews];
            }
        }
        
        if (animated)
            [self layoutSubviews];
        else
            [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat separatorHeight = TGScreenPixel;
    CGFloat separatorInset = _selectionEnabled ? 98 : (TGIsPad() ? 74.0f : 65.0f);
    if (TGIsPad() && _selectionEnabled)
        separatorInset += 21.0f;
    _separatorLayer.frame = CGRectMake(separatorInset, self.frame.size.height - separatorHeight, self.frame.size.width - separatorInset, separatorHeight);
    
    CGRect frame = self.selectedBackgroundView.frame;
    frame.origin.y = true ? -1 : 0;
    frame.size.height = self.frame.size.height + 1;
    self.selectedBackgroundView.frame = frame;
    
    CGSize viewSize = self.contentView.frame.size;
    
    int leftPadding = _selectionEnabled ? (TGIsPad() ? 45.0f : 34.0f) : 0;
    if (self.editing)
        leftPadding += 2;
    
    int avatarWidth = 5 + 40;
    if (TGIsPad())
        avatarWidth += 8;
    
    CGSize titleSizeGeneric = CGSizeMake(viewSize.width - avatarWidth - 9 - 5 - leftPadding, _contactContentsView.titleFont.lineHeight);
    
    CGSize subtitleSize = CGSizeMake(viewSize.width - avatarWidth - 9 - 5 - leftPadding, _subtitleLabel.font.lineHeight);
    
    CGRect avatarFrame = CGRectMake(leftPadding + 14, 4.0f, 40, 40);
    if (TGIsPad())
        avatarFrame = CGRectMake(leftPadding + 19, 5.0f, 45, 45);
    
    if (!CGRectEqualToRect(_avatarView.frame, avatarFrame))
    {
        _avatarView.frame = avatarFrame;
    }
    
    if (_checkButton != nil)
    {
        _checkButton.frame = CGRectMake(_selectionEnabled ? (12 + (TGIsPad() ? 14.0f : 0.0f)) : (-12 - _checkButton.frame.size.width), CGFloor((self.frame.size.height - 22) / 2.0f), 22, 22);
    }
    
    int titleLabelsY = 0;
    
    if (_subtitleLabel.hidden)
    {
        titleLabelsY = (int)((int)((viewSize.height - titleSizeGeneric.height) / 2) - (_hideAvatar ? 0 : 1));
        if (TGIsPad())
            titleLabelsY += 1;
    }
    else
    {
        titleLabelsY = (int)((viewSize.height - titleSizeGeneric.height - subtitleSize.height - 1) / 2);
        if (TGIsPad())
            titleLabelsY += 1;
        
        [_subtitleLabel measureTextSize];
        _subtitleLabel.frame = CGRectMake(avatarWidth + 21 + leftPadding, titleLabelsY + titleSizeGeneric.height + 1.0f + (TGIsPad() ? 1.0f : TGRetinaPixel), subtitleSize.width, subtitleSize.height);
    }
    
    _contactContentsView.titleOffset = CGPointMake(avatarWidth + 21 + leftPadding, titleLabelsY);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    bool wasSelected = self.selected;
    [super setSelected:selected animated:animated];
    
    if (selected || wasSelected)
    {
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = true ? -1 : 0;
        frame.size.height = self.frame.size.height + 1;
        self.selectedBackgroundView.frame = frame;
        
        [self adjustOrdering];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    bool wasHighlighted = self.highlighted;
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted || wasHighlighted)
    {
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = true ? -1 : 0;
        frame.size.height = self.frame.size.height + 1;
        self.selectedBackgroundView.frame = frame;
        
        [self adjustOrdering];
    }
    
    if (_selectionEnabled)
    {
        if (highlighted)
        {
            if (_highlightedBackgroundView == nil)
            {
                _highlightedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -1, self.frame.size.width, self.contentView.frame.size.height + 1)];
                _highlightedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                _highlightedBackgroundView.backgroundColor = UIColorRGB(0xe9eff5);
                
                UIView *topStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _highlightedBackgroundView.frame.size.width, 1)];
                topStripe.backgroundColor = UIColorRGB(0xd5dee5);
                [_highlightedBackgroundView addSubview:topStripe];
                
                UIView *bottomStripe = [[UIView alloc] initWithFrame:CGRectMake(0, _highlightedBackgroundView.frame.size.height - 1, _highlightedBackgroundView.frame.size.width, 1)];
                bottomStripe.backgroundColor = UIColorRGB(0xd5dee5);
                [_highlightedBackgroundView addSubview:bottomStripe];
                
                //[self.contentView insertSubview:_highlightedBackgroundView atIndex:0];
            }
            
            _highlightedBackgroundView.hidden = false;
        }
        else
        {
            if (_highlightedBackgroundView != nil)
                _highlightedBackgroundView.hidden = true;
        }
    }
}

- (void)adjustOrdering
{
    if ([self.superview isKindOfClass:[UITableView class]])
    {
        Class UITableViewCellClass = [UITableViewCell class];
        Class UISearchBarClass = [UISearchBar class];
        int maxCellIndex = 0;
        int index = -1;
        int selfIndex = 0;
        for (UIView *view in self.superview.subviews)
        {
            index++;
            if ([view isKindOfClass:UITableViewCellClass] || [view isKindOfClass:UISearchBarClass])
            {
                maxCellIndex = index;
                
                if (view == self)
                    selfIndex = index;
            }
        }
        
        if (selfIndex < maxCellIndex)
        {
            [self.superview insertSubview:self atIndex:maxCellIndex];
        }
    }
}

@end
