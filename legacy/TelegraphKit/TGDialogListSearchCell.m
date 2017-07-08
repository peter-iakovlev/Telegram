#import "TGDialogListSearchCell.h"

#import "TGLetteredAvatarView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGLabel.h"

#import "TGStringUtils.h"

#import "TGColor.h"

@interface TGDialogListSearchCell ()
{
    CALayer *_separatorLayer;
    int _boldMode;
}

@property (nonatomic, strong) TGLetteredAvatarView *avatarView;

@property (nonatomic, strong) UILabel *titleLabelFirst;
@property (nonatomic, strong) UILabel *titleLabelSecond;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UIImageView *unreadCountBackgrond;
@property (nonatomic, strong) TGLabel *unreadCountLabel;

@property (nonatomic, strong) UIImageView *verifiedIcon;

@end

@implementation TGDialogListSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assetsSource:(id<TGDialogListCellAssetsSource>)assetsSource
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.superview.clipsToBounds = false;
        
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.contentView.layer addSublayer:_separatorLayer];
        
        self.backgroundView = nil;
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        _assetsSource = assetsSource;
        
        _titleLabelFirst = [[UILabel alloc] init];
        _titleLabelFirst.textAlignment = NSTextAlignmentLeft;
        _titleLabelFirst.textColor = UIColorRGB(0x000000);
        _titleLabelFirst.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabelFirst];
        
        _titleLabelSecond = [[UILabel alloc] init];
        _titleLabelSecond.textAlignment = NSTextAlignmentLeft;
        _titleLabelSecond.textColor = UIColorRGB(0x000000);
        _titleLabelSecond.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabelSecond];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        _subtitleLabel.font = TGSystemFontOfSize(14.0f);
        _subtitleLabel.textColor = UIColorRGB(0x949494);
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_subtitleLabel];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:true];
        _avatarView.fadeTransition = true;
        [self.contentView addSubview:_avatarView];
        
        _verifiedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChannelVerifiedIconSmall.png"]];
        _verifiedIcon.hidden = true;
        [self.contentView addSubview:_verifiedIcon];
        
        static UIImage *unreadBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 20.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, UIColorRGB(0x0f94f3).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 20.0f, 20.0f));
            
            unreadBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
        });
        
        _unreadCountBackgrond = [[UIImageView alloc] initWithImage:unreadBackground];
        
        [self.contentView addSubview:_unreadCountBackgrond];
        
        _unreadCountLabel = [[TGLabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
        _unreadCountLabel.textColor = [UIColor whiteColor];
        _unreadCountLabel.font = TGSystemFontOfSize(14);
        
        [self.contentView addSubview:_unreadCountLabel];
        
        _unreadCountLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setBoldMode:(int)index
{
    _boldMode = index;
}

- (void)resetView:(bool)animated
{
    CGFloat titleFontSize = _attributedSubtitleText.length == 0 ? 19.0f : 17.0f;
    if (_boldMode == 0)
    {
        _titleLabelFirst.font = TGSystemFontOfSize(titleFontSize);
        _titleLabelSecond.font = TGMediumSystemFontOfSize(titleFontSize);
    }
    else if (_boldMode == 1)
    {
        _titleLabelFirst.font = TGMediumSystemFontOfSize(titleFontSize);
        _titleLabelSecond.font = TGSystemFontOfSize(titleFontSize);
    }
    else
    {
        _titleLabelFirst.font = TGSystemFontOfSize(titleFontSize);
        _titleLabelSecond.font = TGSystemFontOfSize(titleFontSize);
    }
    
    if (_titleTextSecond == nil || _titleTextSecond.length == 0)
    {
        _titleLabelFirst.text = nil;
        _titleLabelFirst.hidden = true;
        
        _titleLabelSecond.text = _titleTextFirst;
    }
    else
    {
        _titleLabelFirst.text = _titleTextFirst;
        _titleLabelFirst.hidden = false;
        
        _titleLabelSecond.text = _titleTextSecond;
    }
    
    _subtitleLabel.attributedText = _attributedSubtitleText;
    
    static UIColor *titleColor = nil;
    static UIColor *encryptedTitleColor = nil;
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^
    {
        titleColor = [UIColor blackColor];
        encryptedTitleColor = UIColorRGB(0x00a629);
    });
    
    _titleLabelFirst.textColor = _isEncrypted ? encryptedTitleColor : titleColor;
    _titleLabelSecond.textColor = _isEncrypted ? encryptedTitleColor : titleColor;
    
    _avatarView.hidden = false;
    
    _verifiedIcon.hidden = _attributedSubtitleText.length == 0 || !_isVerified;
    
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0f, 40.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 40.0f, 40.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 39.0f, 39.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (_avatarUrl != nil)
    {
        _avatarView.fadeTransitionDuration = animated ? 0.14 : 0.3;
        if (![_avatarUrl isEqualToString:_avatarView.currentUrl])
        {
            if (animated)
            {
                UIImage *currentImage = [_avatarView currentImage];
                [_avatarView loadImage:_avatarUrl filter:@"circle:40x40" placeholder:(currentImage != nil ? currentImage : (_isChat ? placeholder : placeholder)) forceFade:true];
            }
            else
                [_avatarView loadImage:_avatarUrl filter:@"circle:40x40" placeholder:(_isChat ? placeholder : placeholder)];
        }
    }
    else
    {
        if (!_isChat || _isEncrypted)
        {
            [_avatarView loadUserPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) uid:_isEncrypted ? _encryptedUserId : (int32_t)_conversationId firstName:_titleTextFirst lastName:_titleTextSecond placeholder:placeholder];
        }
        else
        {
            [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) conversationId:_conversationId title:_titleTextFirst placeholder:placeholder];
        }
    }
    
    if (_unreadCount != 0)
    {
        _unreadCountBackgrond.hidden = false;
        _unreadCountLabel.hidden = false;
        
        int totalCount = _unreadCount;
        
        if (TGIsLocaleArabic())
        {
            _unreadCountLabel.text = [TGStringUtils stringWithLocalizedNumberCharacters:[[NSString alloc] initWithFormat:@"%d", totalCount]];
        }
        else
        {
            if (totalCount < 1000)
                _unreadCountLabel.text = [[NSString alloc] initWithFormat:@"%d", totalCount];
            else
                _unreadCountLabel.text = [[NSString alloc] initWithFormat:@"%dK", totalCount / 1000];
        }
    }
    else
    {
        _unreadCountBackgrond.hidden = true;
        _unreadCountLabel.hidden = true;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_separatorLayer != nil) {
        CGFloat separatorHeight = TGScreenPixel;
        _separatorLayer.frame = CGRectMake(65.0f, self.frame.size.height - separatorHeight, self.frame.size.width - 65.0f, separatorHeight);
    }
    
    CGRect frame = self.selectedBackgroundView.frame;
    frame.origin.y = true ? -1 : 0;
    frame.size.height = self.frame.size.height + (true ? 1 : 0);
    self.selectedBackgroundView.frame = frame;
    
    CGSize viewSize = self.contentView.frame.size;
    
    CGFloat leftPadding = 0.0f;
    CGFloat rightPadding = 10.0f;
    
    CGFloat countTextWidth = [_unreadCountLabel.text sizeWithFont:_unreadCountLabel.font].width;
    
    CGFloat backgroundWidth = MAX(20.0f, countTextWidth + 11.0f);
    CGRect unreadCountBackgroundFrame = CGRectMake(frame.size.width - 11.0f - backgroundWidth, 15.0f, backgroundWidth, 20.0f);
    _unreadCountBackgrond.frame = unreadCountBackgroundFrame;
    CGRect unreadCountLabelFrame = _unreadCountLabel.frame;
    unreadCountLabelFrame.origin = CGPointMake(unreadCountBackgroundFrame.origin.x + TGRetinaFloor(((unreadCountBackgroundFrame.size.width - countTextWidth) / 2.0f)) - (TGIsRetina() ? 0.0f : 0.0f), unreadCountBackgroundFrame.origin.y + 1.0f -TGRetinaPixel);
    _unreadCountLabel.frame = unreadCountLabelFrame;
    
    if (!_unreadCountBackgrond.hidden)
        rightPadding += unreadCountBackgroundFrame.size.width + 16;
    
    int avatarWidth = 5 + 40;
    
    CGSize titleSizeGeneric = CGSizeMake(viewSize.width - avatarWidth - 21 - leftPadding - rightPadding, _titleLabelFirst.font.lineHeight);
    
    if (!_verifiedIcon.hidden) {
        titleSizeGeneric.width -= _verifiedIcon.bounds.size.width + 5.0f;
    }
    
    CGRect avatarFrame = CGRectMake(leftPadding + 14, 5, 40, 40);
    if (!CGRectEqualToRect(_avatarView.frame, avatarFrame))
        _avatarView.frame = avatarFrame;
    
    CGFloat titleWidth = 0.0f;
    CGFloat titleLabelsY = 0.0f;
    
    if (_attributedSubtitleText.length == 0)
    {
        titleLabelsY = (int)((int)((viewSize.height - titleSizeGeneric.height) / 2));
        
        if (!_titleLabelFirst.hidden)
        {
            _titleLabelFirst.frame = CGRectMake(avatarWidth + 21 + leftPadding, titleLabelsY, titleSizeGeneric.width, titleSizeGeneric.height);
            CGFloat firstWidth = (int)([_titleLabelFirst.text sizeWithFont:_titleLabelFirst.font].width) + 5;
            CGFloat x = _titleLabelFirst.frame.origin.x + firstWidth;
            _titleLabelSecond.frame = CGRectMake(x, titleLabelsY, titleSizeGeneric.width - firstWidth, titleSizeGeneric.height);
            
            titleWidth = CGCeil([_titleLabelFirst.text sizeWithFont:_titleLabelFirst.font].width) + CGCeil([_titleLabelSecond.text sizeWithFont:_titleLabelSecond.font].width);
        }
        else
        {
            _titleLabelSecond.frame = CGRectMake(avatarWidth + 21 + leftPadding, titleLabelsY, titleSizeGeneric.width, titleSizeGeneric.height);
            
            titleWidth = CGCeil([_titleLabelSecond.text sizeWithFont:_titleLabelSecond.font].width);
        }
    }
    else
    {
        titleLabelsY = 4.0f + TGRetinaPixel;
        
        if (!_titleLabelFirst.hidden)
        {
            _titleLabelFirst.frame = CGRectMake(avatarWidth + 21 + leftPadding, titleLabelsY, titleSizeGeneric.width, titleSizeGeneric.height);
            _titleLabelSecond.frame = CGRectMake(avatarWidth + 21 + leftPadding + 5 + (int)([_titleLabelFirst.text sizeWithFont:_titleLabelFirst.font].width), titleLabelsY, titleSizeGeneric.width, titleSizeGeneric.height);
            
            titleWidth = CGCeil([_titleLabelFirst.text sizeWithFont:_titleLabelFirst.font].width) + CGCeil([_titleLabelSecond.text sizeWithFont:_titleLabelSecond.font].width);
        }
        else
        {
            _titleLabelSecond.frame = CGRectMake(avatarWidth + 21 + leftPadding, titleLabelsY, titleSizeGeneric.width, titleSizeGeneric.height);
            
            titleWidth = CGCeil([_titleLabelSecond.text sizeWithFont:_titleLabelSecond.font].width);
        }
        
        CGSize subtitleSize = [_subtitleLabel sizeThatFits:CGSizeMake(titleSizeGeneric.width, CGFLOAT_MAX)];
        subtitleSize = (CGSize){CGCeil(subtitleSize.width), CGCeil(subtitleSize.height)};
        _subtitleLabel.frame = CGRectMake(avatarWidth + 21 + leftPadding, 26.0f, subtitleSize.width, subtitleSize.height);
    }
    
    if (!_verifiedIcon.hidden) {
        _verifiedIcon.frame = CGRectOffset(_verifiedIcon.bounds, avatarWidth + 21 + leftPadding + titleWidth + 3.0f, titleLabelsY + 5.0f - TGRetinaPixel);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = true ? -1 : 0;
        frame.size.height = self.frame.size.height + (true ? 1 : 0);
        self.selectedBackgroundView.frame = frame;
        
        [self adjustOrdering];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = true ? -1 : 0;
        frame.size.height = self.frame.size.height + (true ? 1 : 0);
        self.selectedBackgroundView.frame = frame;
        
        [self adjustOrdering];
    }
}

- (void)adjustOrdering
{
    if ([self.superview isKindOfClass:[UITableView class]])
    {
        Class UITableViewCellClass = [UITableViewCell class];
        int maxCellIndex = 0;
        int index = -1;
        int selfIndex = 0;
        for (UIView *view in self.superview.subviews)
        {
            index++;
            if ([view isKindOfClass:UITableViewCellClass])
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

- (UIView *)avatarSnapshotView
{
    return [_avatarView snapshotViewAfterScreenUpdates:false];
}

- (CGRect)avatarFrame
{
    CGRect frame = self.bounds;
    frame.size.width = CGRectGetMaxX(_avatarView.frame) + _avatarView.frame.origin.x;
    return frame;
}

- (CGRect)textContentFrame
{
    return self.bounds;
//    CGRect frame = self.bounds;
//    frame.origin.x = CGRectGetMaxX(_avatarView.frame) + _avatarView.frame.origin.x;
//    frame.size.width -= frame.origin.x;
//    
//    return frame;
}

@end
