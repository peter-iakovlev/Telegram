#import "TGAppSessionItemView.h"

#import <LegacyComponents/LegacyComponents.h>
#import <LegacyComponents/TGLetteredAvatarView.h>

#import "TGAppSession.h"

#import "TGPresentation.h"

@interface TGAppSessionItemView ()
{
    UILabel *_titleLabel;
    UILabel *_infoLabel;
    UILabel *_subtitleLabel;
    UILabel *_statusLabel;
    TGLetteredAvatarView *_avatarView;
}

@end

@implementation TGAppSessionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.optionText = TGLocalized(@"AuthSessions.LogOut");
        
        _avatarView = [[TGLetteredAvatarView alloc] init];
        [_avatarView setSingleFontSize:10 doubleFontSize:10 useBoldFont:false];
        [self.editingContentView addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(15.0f);
        [self.editingContentView addSubview:_titleLabel];
        
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textColor = [UIColor blackColor];
        _infoLabel.font = TGSystemFontOfSize(13.0f);
        [self.editingContentView addSubview:_infoLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = UIColorRGB(0x808080);
        _subtitleLabel.font = TGSystemFontOfSize(13.0f);
        [self.editingContentView addSubview:_subtitleLabel];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textAlignment = NSTextAlignmentLeft;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = TGSystemFontOfSize(14.0f);
        [self.editingContentView addSubview:_statusLabel];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.textColor = presentation.pallete.collectionMenuTextColor;
    _infoLabel.textColor = presentation.pallete.collectionMenuTextColor;
    _subtitleLabel.textColor = presentation.pallete.collectionMenuVariantColor;
}

- (void)setAppSession:(TGAppSession *)appSession
{
    _titleLabel.text = appSession.bot.displayName;
    _infoLabel.text = appSession.domain;
    
    if (appSession.browser.length != 0)
        _infoLabel.text = [_infoLabel.text stringByAppendingFormat:@", %@", appSession.browser];
    
    if (appSession.platform.length != 0)
        _infoLabel.text = [_infoLabel.text stringByAppendingFormat:@", %@", appSession.platform];
    
    NSString *locationString = [[NSString alloc] initWithFormat:@"%@ • %@", appSession.ip, appSession.region];
    _subtitleLabel.text = locationString;
    
    _statusLabel.text = [TGDateUtils stringForMessageListDate:appSession.dateActive];
    _statusLabel.textColor = self.presentation.pallete.collectionMenuVariantColor;
    
    UIImage *placeholder = [self.presentation.images avatarPlaceholderWithDiameter:20.0f];
    
    if (appSession.bot.photoUrlSmall.length == 0)
    {
        [_avatarView loadUserPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) uid:appSession.bot.uid firstName:appSession.bot.firstName lastName:appSession.bot.lastName placeholder:placeholder];
    }
    else
    {
        [_avatarView loadImage:appSession.bot.photoUrlSmall filter:@"circle:20x20" placeholder:placeholder];
    }

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize statusSize = [_statusLabel.text sizeWithFont:_statusLabel.font];
    statusSize.width = CGCeil(statusSize.width);
    statusSize.height = CGCeil(statusSize.height);
    _statusLabel.frame = CGRectMake(self.editingContentView.frame.size.width - statusSize.width - 12.0f - self.safeAreaInset.right, 9.0f, statusSize.width, statusSize.height);
    
    CGFloat leftInset = 16.0f + (self.enableEditing && self.showsDeleteIndicator ? 38.0f : 0.0f) + self.safeAreaInset.left;
    
    _avatarView.frame = CGRectMake(leftInset, 7.0f, 20.0f, 20.0f);
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(CGCeil(titleSize.width), _statusLabel.frame.origin.x - 10.0f - leftInset);
    titleSize.height = CGCeil(titleSize.height);
    _titleLabel.frame = CGRectMake(leftInset + 26.0f, 8.0f + TGRetinaPixel, titleSize.width, titleSize.height);
    
    CGSize infoSize = [_infoLabel.text sizeWithFont:_subtitleLabel.font];
    infoSize.width = MIN(CGCeil(infoSize.width), self.editingContentView.frame.size.width - leftInset * 2.0f);
    infoSize.height = CGCeil(infoSize.height);
    _infoLabel.frame = CGRectMake(leftInset, 30.0f, infoSize.width, infoSize.height);
    
    CGSize subtitleSize = [_subtitleLabel.text sizeWithFont:_subtitleLabel.font];
    subtitleSize.width = MIN(CGCeil(subtitleSize.width), self.editingContentView.frame.size.width - leftInset * 2.0f);
    subtitleSize.height = CGCeil(subtitleSize.height);
    _subtitleLabel.frame = CGRectMake(leftInset, 49.0f, subtitleSize.width, subtitleSize.height);
}

- (void)deleteAction
{
    [super deleteAction];
    
    if (_removeRequested)
        _removeRequested();
}

@end

