#import "TGDialogListSearchCell.h"

#import "TGLetteredAvatarView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGDialogListSearchCell ()
{
    CALayer *_separatorLayer;
}

@property (nonatomic, strong) TGLetteredAvatarView *avatarView;

@property (nonatomic, strong) UILabel *titleLabelFirst;
@property (nonatomic, strong) UILabel *titleLabelSecond;

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
        _titleLabelFirst.contentMode = UIViewContentModeLeft;
        _titleLabelFirst.font = TGSystemFontOfSize(19);
        _titleLabelFirst.textColor = UIColorRGB(0x000000);
        _titleLabelFirst.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabelFirst];
        
        _titleLabelSecond = [[UILabel alloc] init];
        _titleLabelSecond.contentMode = UIViewContentModeLeft;
        _titleLabelSecond.font = TGMediumSystemFontOfSize(19);
        _titleLabelSecond.textColor = UIColorRGB(0x000000);
        _titleLabelSecond.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabelSecond];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        [_avatarView setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
        _avatarView.fadeTransition = true;
        [self.contentView addSubview:_avatarView];
    }
    return self;
}

- (void)setBoldMode:(int)index
{
    if (index == 0)
    {
        _titleLabelFirst.font = [UIFont systemFontOfSize:19];
        _titleLabelSecond.font = [UIFont boldSystemFontOfSize:19];
    }
    else if (index == 1)
    {
        _titleLabelFirst.font = [UIFont boldSystemFontOfSize:19];
        _titleLabelSecond.font = [UIFont systemFontOfSize:19];
    }
    else
    {
        _titleLabelFirst.font = [UIFont systemFontOfSize:19];
        _titleLabelSecond.font = [UIFont systemFontOfSize:19];
    }
}

- (void)resetView:(bool)animated
{
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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    _separatorLayer.frame = CGRectMake(65.0f, self.frame.size.height - separatorHeight, self.frame.size.width - 65.0f, separatorHeight);
    
    CGRect frame = self.selectedBackgroundView.frame;
    frame.origin.y = true ? -1 : 0;
    frame.size.height = self.frame.size.height + (true ? 1 : 0);
    self.selectedBackgroundView.frame = frame;
    
    CGSize viewSize = self.contentView.frame.size;
    
    const int leftPadding = 0;
    
    int avatarWidth = 5 + 40;
    
    CGSize titleSizeGeneric = CGSizeMake(viewSize.width - avatarWidth - 9 - 5 - leftPadding, _titleLabelFirst.font.lineHeight);
    
    CGRect avatarFrame = CGRectMake(leftPadding + 14, 5, 40, 40);
    if (!CGRectEqualToRect(_avatarView.frame, avatarFrame))
        _avatarView.frame = avatarFrame;
    
    int titleLabelsY = 0;
    titleLabelsY = (int)((int)((viewSize.height - titleSizeGeneric.height) / 2) - 1);
    
    if (!_titleLabelFirst.hidden)
    {
        _titleLabelFirst.frame = CGRectMake(avatarWidth + 21 + leftPadding, titleLabelsY, titleSizeGeneric.width, titleSizeGeneric.height);
        _titleLabelSecond.frame = CGRectMake(avatarWidth + 21 + leftPadding + 5 + (int)([_titleLabelFirst.text sizeWithFont:_titleLabelFirst.font].width), titleLabelsY, titleSizeGeneric.width, titleSizeGeneric.height);
    }
    else
    {
        _titleLabelSecond.frame = CGRectMake(avatarWidth + 21 + leftPadding, titleLabelsY, titleSizeGeneric.width, titleSizeGeneric.height);
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

@end
