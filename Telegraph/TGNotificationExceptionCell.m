#import "TGNotificationExceptionCell.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import <LegacyComponents/TGLetteredAvatarView.h>
#import "TGDialogListCellEditingControls.h"

#import "TGPresentation.h"
#import "TGNotificationException.h"

#import "TGAlertSoundController.h"

@interface TGNotificationExceptionCell ()
{
    CALayer *_separatorLayer;
    
    TGDialogListCellEditingControls *_wrapView;
    TGLetteredAvatarView *_avatarView;
    
    UILabel *_nameLabel;
    UILabel *_subLabel;
    
    TGNotificationException *_exception;
}
@end

@implementation TGNotificationExceptionCell

@dynamic deletePressed;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        if (iosMajorVersion() >= 7)
        {
            self.contentView.superview.clipsToBounds = false;
        }
        
        if (iosMajorVersion() <= 6) {
            _separatorLayer = [[CALayer alloc] init];
            _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
            [self.layer addSublayer:_separatorLayer];
        }
        
        self.selectedBackgroundView = [[UIView alloc] init];
        
        _wrapView = [[TGDialogListCellEditingControls alloc] init];
        _wrapView.clipsToBounds = true;
        [_wrapView setLabelOnly:true];
        [self addSubview:_wrapView];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(10, 7 - TGScreenPixel, 62 + TGScreenPixel, 62 + TGScreenPixel)];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:false];
        _avatarView.fadeTransition = cpuCoreCount() > 1;
        [_wrapView addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = TGSystemFontOfSize(17.0f);
        _nameLabel.textColor = UIColorRGB(0x000000);
        [_wrapView addSubview:_nameLabel];
        
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = TGSystemFontOfSize(14.0f);
        _subLabel.textColor = UIColorRGB(0x8e8e93);
        [_wrapView addSubview:_subLabel];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    
    [_wrapView setPresentation:presentation];
    
    self.backgroundColor = presentation.pallete.backgroundColor;
    
    _subLabel.backgroundColor = self.backgroundColor;
    _subLabel.textColor = presentation.pallete.secondaryTextColor;
    _nameLabel.backgroundColor = self.backgroundColor;
    _nameLabel.textColor = presentation.pallete.textColor;
    
    _separatorLayer.backgroundColor = presentation.pallete.separatorColor.CGColor;
    self.selectedBackgroundView.backgroundColor = presentation.pallete.selectionColor;
}

+ (NSString *)stringForRemainingMuteInterval:(int)value
{
    value = MAX(1 * 60, value);
    
    if (value <= 1 * 60 * 60)
    {
        value = (int)roundf(value / 60.0f);
        NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Notifications.ExceptionMuteExpires.Minutes_" value:value]);
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", value]];
    }
    else if (value <= 24 * 60 * 60)
    {
        value = (int)roundf(value / (60.0f * 60.0f));
        NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Notifications.ExceptionMuteExpires.Hours_" value:value]);
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", value]];
    }
    else
    {
        value = (int)roundf(value / (24.0f * 60.0f * 60.0f));
        NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Notifications.ExceptionMuteExpires.Days_" value:value]);
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", value]];
    }
    
    return @"";
}

- (void)setException:(TGNotificationException *)exception peers:(NSDictionary *)peers
{
    _exception = exception;
    
    id peer = peers[@(exception.peerId)];
    NSString *photoUrlSmall = nil;
    NSString *firstName = nil;
    NSString *lastName = nil;
    NSString *title = nil;
    if ([peer isKindOfClass:[TGUser class]]) {
        firstName = ((TGUser *)peer).firstName;
        lastName = ((TGUser *)peer).lastName;
        photoUrlSmall = ((TGUser *)peer).photoFullUrlSmall;
        _nameLabel.text = ((TGUser *)peer).displayName;
    } else if ([peer isKindOfClass:[TGConversation class]]) {
        title = ((TGConversation *)peer).chatTitle;
        photoUrlSmall = ((TGConversation *)peer).chatPhotoFullSmall;
        _nameLabel.text = title;
    }
    [_nameLabel sizeToFit];
    
    CGFloat diameter = TGIsPad() ? 45.0f : 40.0f;
    
    UIImage *placeholder = [self.presentation.images avatarPlaceholderWithDiameter:diameter];
    bool animateState = false;
    if (photoUrlSmall.length != 0)
    {
        _avatarView.fadeTransitionDuration = animateState ? 0.14 : 0.3;
        if (![photoUrlSmall isEqualToString:_avatarView.currentUrl])
        {
            if (animateState)
            {
                UIImage *currentImage = [_avatarView currentImage];
                [_avatarView loadImage:photoUrlSmall filter:TGIsPad() ? @"circle:45x45" : @"circle:40x40" placeholder:(currentImage != nil ? currentImage : placeholder) forceFade:true];
            }
            else
            {
                [_avatarView loadImage:photoUrlSmall filter:TGIsPad() ? @"circle:45x45" : @"circle:40x40" placeholder:placeholder];
            }
        }
    }
    else
    {
        CGSize size = CGSizeMake(diameter, diameter);
        if (TGPeerIdIsUser(exception.peerId)) {
            [_avatarView loadUserPlaceholderWithSize:size uid:(int32_t)exception.peerId firstName:firstName lastName:lastName placeholder:placeholder];
        } else {
            [_avatarView loadGroupPlaceholderWithSize:size conversationId:exception.peerId title:title placeholder:placeholder];
        }
    }
    
    NSMutableArray *components = [[NSMutableArray alloc] init];
    if (exception.muteUntil != nil)
    {
        NSString *muteText = nil;
        if (exception.muteUntil.intValue <= [[TGTelegramNetworking instance] approximateRemoteTime]) {
            muteText = TGLocalized(@"Notifications.ExceptionsUnmuted");
        } else {
            int muteExpiration = exception.muteUntil.intValue - (int)[[TGTelegramNetworking instance] approximateRemoteTime];
            if (muteExpiration >= 7 * 24 * 60 * 60)
                muteText = TGLocalized(@"Notifications.ExceptionsMuted");
            else
                muteText = [TGNotificationExceptionCell stringForRemainingMuteInterval:muteExpiration];
        }
        
        [components addObject:muteText];
    }
    if (exception.notificationType != nil)
    {
        NSString *soundName = [TGAlertSoundController soundNameFromId:exception.notificationType.intValue];
        if (soundName != nil)
            [components addObject:soundName];
    }
    _subLabel.text = [components componentsJoinedByString:@", "];
    [_subLabel sizeToFit];
}

- (void)setDeletePressed:(void (^)(void))deletePressed
{
    _wrapView.requestDelete = deletePressed;
}

- (void)prepareForReuse
{
    [_wrapView setExpanded:false animated:false];
    
    [super prepareForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentOffset = self.contentView.frame.origin.x;
    CGFloat contentWidth = self.contentView.frame.size.width;
    
    [_wrapView setExpandable:contentOffset <= FLT_EPSILON];
    
    static Class separatorClass = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        separatorClass = NSClassFromString(TGEncodeText(@"`VJUbcmfWjfxDfmmTfqbsbupsWjfx", -1));
    });
    for (UIView *subview in self.subviews) {
        if (subview.class == separatorClass) {
            CGRect frame = subview.frame;
            if (_isLastCell) {
                frame.size.width = self.bounds.size.width;
                frame.origin.x = 0.0f;
            } else {
                if (contentOffset > FLT_EPSILON) {
                    frame.size.width = self.bounds.size.width - 101.0f;
                    frame.origin.x = 101.0f;
                } else {
                    frame.size.width = self.bounds.size.width - 65.0f;
                    frame.origin.x = 65.0f;
                }
            }
            if (!CGRectEqualToRect(subview.frame, frame)) {
                subview.frame = frame;
            }
            break;
        }
    }
    
    static CGSize screenSize;
    static CGFloat widescreenWidth;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        screenSize = TGScreenSize();
        widescreenWidth = MAX(screenSize.width, screenSize.height);
    });
    
    CGSize rawSize = self.frame.size;
    CGSize size = rawSize;
    if (!TGIsPad())
    {
        if ([TGViewController hasTallScreen])
        {
            size.width = contentWidth;
        }
        else
        {
            if (rawSize.width >= widescreenWidth - FLT_EPSILON)
                size.width = screenSize.height - contentOffset;
            else
                size.width = screenSize.width - contentOffset;
        }
    }
    else
        size.width = rawSize.width - contentOffset;
        
        _wrapView.frame = CGRectMake(contentOffset, 0.0f, size.width, size.height);
        
        CGFloat separatorHeight = TGScreenPixel;
        CGFloat separatorInset = 86.0f;
        
        _separatorLayer.frame = CGRectMake(separatorInset, self.frame.size.height - separatorHeight, self.frame.size.width - separatorInset, separatorHeight);
        
        CGRect frame = self.selectedBackgroundView.frame;
        frame.origin.y = -1;
        frame.size.height = self.frame.size.height + 1;
        self.selectedBackgroundView.frame = frame;
        
        CGFloat leftPadding = 15.0f;
        if (self.editing)
            leftPadding += 2;
            
        CGRect avatarFrame = CGRectMake(leftPadding, 8.0f, 40, 40);
        if (TGIsPad())
            avatarFrame = CGRectMake(leftPadding, 6.0f, 45, 45);
    
        if (!CGRectEqualToRect(_avatarView.frame, avatarFrame))
            _avatarView.frame = avatarFrame;
    
        leftPadding = CGRectGetMaxX(avatarFrame) + 12.0f;

        _nameLabel.frame = CGRectMake(leftPadding, 8.0f, size.width - leftPadding - 8.0f, _nameLabel.frame.size.height);
        _subLabel.frame = CGRectMake(leftPadding, 31.0f, size.width - leftPadding - 8.0f, _subLabel.frame.size.height);

}

- (void)setIsLastCell:(bool)isLastCell {
    if (_isLastCell != isLastCell) {
        _isLastCell = isLastCell;
        [self setNeedsLayout];
    }
}

- (bool)isEditingControlsExpanded {
    return [_wrapView isExpanded];
}

- (void)setEditingConrolsExpanded:(bool)expanded animated:(bool)animated {
    [_wrapView setExpanded:expanded animated:animated];
}

@end
