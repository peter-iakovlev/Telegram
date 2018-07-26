#import "TGConversationSwitchCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGIconSwitchView.h>

#import "TGPresentation.h"

@interface TGConversationSwitchCollectionItemView ()
{
    UILabel *_titleLabel;
    UISwitch *_switchView;
    TGLetteredAvatarView *_avatarView;
    
    NSString *_avatarUrl;
}

@end

@implementation TGConversationSwitchCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _avatarView = [[TGLetteredAvatarView alloc] init];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:false];
        [self addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];

        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_switchView];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.textColor = presentation.pallete.collectionMenuTextColor;
    if ([_switchView isKindOfClass:[UISwitch class]] && [_switchView respondsToSelector:@selector(setOnTintColor:)])
    {
        _switchView.onTintColor = presentation.pallete.collectionMenuSwitchColor;
        if (presentation.pallete.collectionMenuSwitchColor != nil)
            _switchView.tintColor = presentation.pallete.collectionMenuAccessoryColor;
        else
            _switchView.tintColor = nil;
    }
}

- (void)setFullSeparator:(bool)fullSeparator {
    self.separatorInset = fullSeparator ? 0.0f : 65.0f;
}

- (void)setConversation:(TGConversation *)conversation
{
    _titleLabel.text = conversation.chatTitle;
    
    UIImage *placeholder = [self.presentation.images avatarPlaceholderWithDiameter:40.0f];    
    if (conversation.chatPhotoSmall.length == 0)
    {
        if (conversation.conversationId < 0)
        {
            [_avatarView loadGroupPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) conversationId:conversation.conversationId title:conversation.chatTitle placeholder:placeholder];
        }
        else
        {
            [_avatarView loadUserPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) uid:(int32_t)conversation.conversationId firstName:nil lastName:nil placeholder:placeholder];
        }
    }
    else
    {
        NSString *uri = conversation.chatPhotoSmall;
        if (!TGStringCompare(_avatarUrl, uri))
        {
            _avatarUrl = uri;
            
            UIImage *currentPlaceholder = placeholder;
            UIImage *currentImage = [_avatarView currentImage];
            if (currentImage != nil)
                currentPlaceholder = currentImage;
            
            [_avatarView loadImage:uri filter:@"circle:40x40" placeholder:nil];
        }
    }
}

- (void)setIsOn:(bool)isOn animated:(bool)animated
{
    [_switchView setOn:isOn animated:animated];
}

- (void)setIsEnabled:(bool)isEnabled {
    _titleLabel.alpha = isEnabled ? 1.0f : 0.5f;
    _switchView.userInteractionEnabled = isEnabled;
    _switchView.alpha = isEnabled ? 1.0f : 0.5f;
}

- (void)switchValueChanged
{
    id<TGConversationSwitchCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(switchCollectionItemViewChangedValue:isOn:)])
        [delegate switchCollectionItemViewChangedValue:self isOn:_switchView.on];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize switchSize = _switchView.bounds.size;
    _switchView.frame = CGRectMake(bounds.size.width - switchSize.width - 15.0f - self.safeAreaInset.right, 8.0f, switchSize.width, switchSize.height);
    
    _avatarView.frame = CGRectMake(13.0f, 4.0f, 40.0f, 40.0f);
    _titleLabel.frame = CGRectMake(65.0f + self.safeAreaInset.left, CGFloor((bounds.size.height - 26.0f) / 2.0f), bounds.size.width - 65.0f - switchSize.width - 24.0f, 26.0f);
}

@end
