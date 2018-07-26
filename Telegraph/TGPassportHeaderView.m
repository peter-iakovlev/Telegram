#import "TGPassportHeaderView.h"

#import "TGPresentation.h"

#import <LegacyComponents/TGUser.h>

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGLetteredAvatarView.h>


@interface TGPassportHeaderView ()
{
    TGPresentation *_presentation;
    
    UIImageView *_logo;
    TGLetteredAvatarView *_avatarView;
    UILabel *_topLabel;
    
    int32_t _userId;
}
@end

@implementation TGPassportHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.userInteractionEnabled = false;
        
        _avatarView = [[TGLetteredAvatarView alloc] init];
        [_avatarView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
        [self addSubview:_avatarView];
        
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = TGSystemFontOfSize(14.0f);
        _topLabel.numberOfLines = 3;
        _topLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_topLabel];
    }
    return self;
}

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    [self layoutSubviews];
}

- (void)setAvatarHidden:(bool)avatarHidden
{
    _avatarHidden = avatarHidden;
    _avatarView.hidden = avatarHidden;
    [self layoutSubviews];
}

- (bool)logoHidden
{
    return _logo == nil || _logo.hidden;
}

- (void)setLogoHidden:(bool)logoHidden
{
    if (!logoHidden && _logo == nil)
    {
        _logo = [[UIImageView alloc] initWithImage:TGTintedImage(TGImageNamed(@"PassportSettingsLogo"), _presentation.pallete.secondaryTextColor)];
        [self addSubview:_logo];
    }
    
    _logo.alpha = logoHidden ? 0.0f : 1.0f;
    _topLabel.hidden = !logoHidden;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    _topLabel.textColor = presentation.pallete.collectionMenuCommentColor;
    
    if (_logo != nil)
        _logo.image = TGTintedImage(TGImageNamed(@"PassportSettingsLogo"), presentation.pallete.secondaryTextColor);
}

- (void)setBot:(TGUser *)bot
{
    if (_userId == bot.uid)
        return;
    
    _userId = bot.uid;
    
    CGFloat diameter = 70.0f;
    NSString *avatarUrl = bot.photoUrlSmall;
    UIImage *placeholder = [_presentation.images avatarPlaceholderWithDiameter:diameter color:_presentation.pallete.collectionMenuBackgroundColor borderColor:_presentation.pallete.collectionMenuSeparatorColor];
    if (avatarUrl.length != 0)
    {
        _avatarView.fadeTransitionDuration = 0.3;
        if (![avatarUrl isEqualToString:_avatarView.currentUrl])
            [_avatarView loadImage:avatarUrl filter:@"circle:70x70" placeholder:placeholder];
    }
    else
    {
        [_avatarView loadUserPlaceholderWithSize:CGSizeMake(diameter, diameter) uid:bot.uid firstName:bot.firstName lastName:bot.lastName placeholder:placeholder];
    }
    
    NSString *formatString = TGLocalized(@"Passport.RequestHeader");
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:formatString, bot.displayName] attributes:@{ NSFontAttributeName: _topLabel.font }];
    
    NSRange nameRange = [formatString rangeOfString:@"%@"];
    if (nameRange.location != NSNotFound)
    {
        nameRange = NSMakeRange(nameRange.location, bot.displayName.length);
        [text addAttribute:NSFontAttributeName value:TGMediumSystemFontOfSize(14.0f) range:nameRange];
    }
    _topLabel.attributedText = text;
    
    [_topLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat diameter = 70.0f;
    _avatarView.frame = CGRectMake(TGScreenPixelFloor((self.frame.size.width - diameter) / 2.0f), 30.0f, diameter, diameter);
    
    _logo.frame = CGRectMake(TGScreenPixelFloor((self.frame.size.width - _logo.frame.size.width) / 2.0f), TGScreenPixelFloor((self.frame.size.height - _logo.frame.size.height) / 2.0f), _logo.frame.size.width, _logo.frame.size.height);
    
    CGSize textSize = [_topLabel.text sizeWithFont:_topLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - 32.0f - self.safeAreaInset.left - self.safeAreaInset.right, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    CGFloat topOffset = _avatarHidden ? 30.0f : 116.0f;
    _topLabel.frame = CGRectMake(TGScreenPixelFloor((self.frame.size.width - textSize.width) / 2.0f), topOffset, textSize.width, textSize.height);
}

@end
