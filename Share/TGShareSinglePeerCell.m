#import "TGShareSinglePeerCell.h"

#import "LegacyDatabase.h"
#import "TGUserModel.h"

#import "TGShareImageView.h"
#import "TGCheckButtonView.h"

@interface TGShareSinglePeerCell ()
{
    TGShareImageView *_avatarView;
    UIImageView *_selectedCircleView;
    TGCheckButtonView *_checkView;
    UILabel *_titleLabel;
    int64_t _peerId;
    bool _isSecret;
    
    bool _isChecked;
    
    bool _showOnlyFirstName;
}
@end

@implementation TGShareSinglePeerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.opaque = true;
        self.backgroundColor = [UIColor whiteColor];
        
        _showOnlyFirstName = true;
        
        _avatarView = [[TGShareImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
        _avatarView.backgroundColor = [UIColor whiteColor];
        _avatarView.opaque = true;
        [self.contentView addSubview:_avatarView];
        
        static UIImage *circleImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(60.0f, 60.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            CGContextSetFillColorWithColor(context, TGColorWithHex(0x007ee5).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 60.0f, 60.0f));
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(2.0f, 2.0f, 60.0f - 4.0f, 60.0f - 4.0f));
            circleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _selectedCircleView = [[UIImageView alloc] initWithImage:circleImage];
        _selectedCircleView.hidden = true;
        [self.contentView addSubview:_selectedCircleView];
        
        _checkView = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleShare];
        _checkView.userInteractionEnabled = false;
        [self.contentView addSubview:_checkView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:11.0f];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)setPeer:(TGUserModel *)peer shareContext:(TGShareContext *)shareContext
{
    NSString *title = nil;
    if (_showOnlyFirstName)
        title = peer.firstName;
    else
        title = [NSString stringWithFormat:@"%@\n%@", peer.firstName, peer.lastName];
    
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    
    CGSize imageSize = CGSizeMake(60.0f, 60.0f);
    if (peer.avatarLocation == nil)
    {
        NSString *letters = @"";
        if (peer.firstName.length != 0 && peer.lastName.length != 0)
        {
            letters = [[NSString alloc] initWithFormat:@"%@%@", [[peer.firstName substringToIndex:1] uppercaseString], [[peer.lastName substringToIndex:1] uppercaseString]];
        }
        else if (peer.firstName.length != 0)
            letters = [[peer.firstName substringToIndex:1] uppercaseString];
        else if (peer.lastName.length != 0)
            letters = [[peer.lastName substringToIndex:1] uppercaseString];
        [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext letters:letters peerId:TGPeerIdPrivateMake(peer.userId) imageSize:imageSize]];
    }
    else
    {
        [_avatarView setSignal:[TGChatListAvatarSignal chatListAvatarWithContext:shareContext location:peer.avatarLocation imageSize:imageSize]];
    }
    
    [self setNeedsLayout];
}

- (void)setChecked:(bool)checked
{
    [UIView performWithoutAnimation:^
    {
        [self setChecked:checked animated:false];
    }];
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    if (_isChecked == checked)
        return;
    
    _isChecked = checked;
    
    _titleLabel.textColor = checked ? TGAccentColor() : [UIColor blackColor];
    
    if (animated)
    {
        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.48f initialSpringVelocity:0.0f options:0 animations:^{
            _avatarView.transform = checked ? CGAffineTransformMakeScale(0.8666666f, 0.8666666f) : CGAffineTransformIdentity;
        } completion:nil];
        [_checkView setSelected:checked animated:true bump:true];
    }
    else
    {
        _avatarView.transform = checked ? CGAffineTransformMakeScale(0.8666666f, 0.8666666f) : CGAffineTransformIdentity;
        [_checkView setSelected:checked animated:false];
    }
    
    _selectedCircleView.hidden = !checked;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [UIView performWithoutAnimation:^
    {
        _avatarView.center = CGPointMake(floor(self.bounds.size.width / 2.0f), _avatarView.center.y);
        _selectedCircleView.center = _avatarView.center;
        _checkView.frame = CGRectMake(self.bounds.size.width / 2.0f + 30.0f - _checkView.frame.size.width + 6.0f, 60.0f - _checkView.frame.size.height + 6.0f, _checkView.frame.size.width, _checkView.frame.size.height);
         
        _titleLabel.frame = CGRectMake(0.0f, 64.0f, self.bounds.size.width, _titleLabel.frame.size.height);
    }];
}

@end
