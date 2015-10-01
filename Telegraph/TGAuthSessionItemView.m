#import "TGAuthSessionItemView.h"

#import "TGAuthSession.h"

#import "TGDateUtils.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGAuthSessionItemView ()
{
    UILabel *_titleLabel;
    UILabel *_infoLabel;
    UILabel *_subtitleLabel;
    UILabel *_statusLabel;
}

@end

@implementation TGAuthSessionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.optionText = TGLocalized(@"Common.Close");
        
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

- (void)setAuthSession:(TGAuthSession *)authSession
{
    _titleLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", authSession.appName, authSession.appVersion];
    
    if ((authSession.flags & 2) == 0)
    {
        _titleLabel.text = [[_titleLabel.text stringByAppendingString:@" "] stringByAppendingFormat:TGLocalized(@"AuthSessions.AppUnofficial"), [[NSString alloc] initWithFormat:@"%d", (int)authSession.apiId]];
    }
    
    _infoLabel.text = [[NSString alloc] initWithFormat:@"%@,", authSession.deviceModel];
    
    if (authSession.platform.length != 0)
        _infoLabel.text = [_infoLabel.text stringByAppendingFormat:@" %@", authSession.platform];
    
    if (authSession.systemVersion.length != 0)
        _infoLabel.text = [_infoLabel.text stringByAppendingFormat:@" %@", authSession.systemVersion];
    
    NSString *locationString = [[NSString alloc] initWithFormat:@"%@ — %@", authSession.ip, authSession.country];
    _subtitleLabel.text = locationString;
    
    if (authSession.sessionHash == 0)
    {
        _statusLabel.text = TGLocalized(@"Presence.online");
        _statusLabel.textColor = TGAccentColor();
    }
    else
    {
        _statusLabel.text = [TGDateUtils stringForMessageListDate:authSession.dateActive];
        _statusLabel.textColor = UIColorRGB(0x999999);
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize statusSize = [_statusLabel.text sizeWithFont:_statusLabel.font];
    statusSize.width = CGCeil(statusSize.width);
    statusSize.height = CGCeil(statusSize.height);
    _statusLabel.frame = CGRectMake(self.editingContentView.frame.size.width - statusSize.width - 12.0f, 9.0f, statusSize.width, statusSize.height);
    
    CGFloat leftInset = 16.0f + (self.enableEditing && self.showsDeleteIndicator ? 38.0f : 0.0f);
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(CGCeil(titleSize.width), _statusLabel.frame.origin.x - 10.0f - leftInset);
    titleSize.height = CGCeil(titleSize.height);
    _titleLabel.frame = CGRectMake(leftInset, 8.0f + TGRetinaPixel, titleSize.width, titleSize.height);
    
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
