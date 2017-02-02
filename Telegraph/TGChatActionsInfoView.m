#import "TGChatActionsInfoView.h"

#import "TGLetteredAvatarView.h"

@interface TGChatActionsInfoView ()
{
    UIImageView *_backgroundView;
    TGLetteredAvatarView *_avatarView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}
@end

@implementation TGChatActionsInfoView

- (instancetype)initWithConversation:(TGConversation *)__unused conversation
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        self.exclusiveTouch = true;
        self.backgroundColor = [UIColor whiteColor];
        
        _backgroundView = [[UIImageView alloc] initWithImage:nil];
        [self addSubview:_backgroundView];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 55.0f, 55.0f)];
        [self addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] init];
        [self addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = UIColorRGB(0x000000);
        [self addSubview:_subtitleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    _titleLabel.frame = CGRectMake(76, 0, 0, 0);
    _subtitleLabel.frame = CGRectMake(76, 0, 0, 0);
}

@end
