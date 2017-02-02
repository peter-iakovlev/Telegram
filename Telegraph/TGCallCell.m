#import "TGCallCell.h"

#import "TGTelegraph.h"

#import "TGMessage.h"
#import "TGUser.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGDateUtils.h"
#import "TGFont.h"

#import "TGLetteredAvatarView.h"
#import "TGModernButton.h"

@interface TGCallCell ()
{
    CALayer *_separatorLayer;
    
    UIImageView *_typeIcon;
    TGLetteredAvatarView *_avatarView;
    
    UILabel *_nameLabel;
    UILabel *_subLabel;
    UILabel *_dateLabel;
    
    TGModernButton *_infoButton;
}
@end

@implementation TGCallCell

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
        
        _typeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 48)];
        _typeIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:_typeIcon];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(10, 7 - TGRetinaPixel, 62 + TGRetinaPixel, 62 + TGRetinaPixel)];
        [_avatarView setSingleFontSize:35.0f doubleFontSize:21.0f useBoldFont:false];
        _avatarView.fadeTransition = cpuCoreCount() > 1;
        [self addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = TGMediumSystemFontOfSize(17.0f);
        _nameLabel.textColor = UIColorRGB(0x000000);
        [self addSubview:_nameLabel];
        
        CGFloat subtitleFontSize = TGIsPad() ? 14.0f : 13.0f;
        
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = TGSystemFontOfSize(subtitleFontSize);
        _subLabel.textColor = UIColorRGB(0x8e8e93);
        [self addSubview:_subLabel];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = TGSystemFontOfSize(subtitleFontSize);
        _dateLabel.textColor = UIColorRGB(0x8e8e93);
        [self addSubview:_dateLabel];
        
        _infoButton = [[TGModernButton alloc] init];
        _infoButton.adjustsImageWhenHighlighted = false;
        [_infoButton setImage:[UIImage imageNamed:@"CallInfoIcon"] forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(infoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_infoButton];
    }
    return self;
}

- (void)setupWithMessage:(TGMessage *)message peer:(TGUser *)peer
{
    _nameLabel.text = [peer displayName];
    [_nameLabel sizeToFit];
    
    _dateLabel.text = [TGDateUtils stringForMessageListDate:(int)message.date];
    [_dateLabel sizeToFit];
    
    TGActionMediaAttachment *actionMedia = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if (attachment.type == TGActionMediaAttachmentType)
        {
            actionMedia = (TGActionMediaAttachment *)attachment;
            break;
        }
    }
    
    bool outgoing = message.fromUid == TGTelegraphInstance.clientUserId;
    bool missed = [actionMedia.actionData[@"reason"] intValue] == TGCallDiscardReasonMissed;
    
    if (missed)
    {
        static dispatch_once_t onceToken;
        static UIImage *missedOutgoingImage;
        static UIImage *missedIncomingImage;
        dispatch_once(&onceToken, ^
        {
            missedOutgoingImage = TGTintedImage([UIImage imageNamed:@"CallOutgoing"], UIColorRGB(0xfc514b));
            missedIncomingImage = TGTintedImage([UIImage imageNamed:@"CallIncoming"], UIColorRGB(0xfc514b));
        });
        _typeIcon.image = outgoing ? missedOutgoingImage : missedIncomingImage;
    }
    else
    {
        _typeIcon.image = outgoing ? [UIImage imageNamed:@"CallOutgoing"] : [UIImage imageNamed:@"CallIncoming"];
    }
    
    NSString *type = TGLocalized(missed ? (outgoing ? @"Notification.CallCanceled" : @"Notification.CallMissed") : (outgoing ? @"Notification.CallOutgoing" : @"Notification.CallIncoming"));
    
    NSString *duration = nil;
    if (!missed)
        duration = [TGStringUtils stringForShortCallDurationSeconds:[actionMedia.actionData[@"duration"] intValue]];
    
    NSString *title = missed ? type : [NSString stringWithFormat:TGLocalized(@"Notification.CallTimeFormat"), type, duration];
    _subLabel.text = title;
    [_subLabel sizeToFit];
    
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
    
    bool animateState = false;
    if (peer.photoUrlSmall.length != 0)
    {
        _avatarView.fadeTransitionDuration = animateState ? 0.14 : 0.3;
        if (![peer.photoUrlSmall isEqualToString:_avatarView.currentUrl])
        {
            if (animateState)
            {
                UIImage *currentImage = [_avatarView currentImage];
                [_avatarView loadImage:peer.photoUrlSmall filter:TGIsPad() ? @"circle:45x45" : @"circle:40x40" placeholder:(currentImage != nil ? currentImage : placeholder) forceFade:true];
            }
            else
                [_avatarView loadImage:peer.photoUrlSmall filter:TGIsPad() ? @"circle:45x45" : @"circle:40x40" placeholder:placeholder];
        }
    }
    else
    {
        [_avatarView loadUserPlaceholderWithSize:CGSizeMake(diameter, diameter) uid:(int32_t)peer.uid firstName:peer.firstName lastName:peer.lastName placeholder:placeholder];
    }

}

- (void)infoButtonPressed
{
    if (self.infoPressed != nil)
        self.infoPressed();
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentOffset = self.contentView.frame.origin.x;
    
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
                    frame.size.width = self.bounds.size.width - 116.0f;
                    frame.origin.x = 116.0f;
                } else {
                    frame.size.width = self.bounds.size.width - 80.0f;
                    frame.origin.x = 80.0f;
                }
            }
            if (!CGRectEqualToRect(subview.frame, frame)) {
                subview.frame = frame;
            }
            break;
        }
    }
    
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    CGFloat separatorInset = 98;
    if (TGIsPad())
        separatorInset += 21.0f;
    _separatorLayer.frame = CGRectMake(separatorInset, self.frame.size.height - separatorHeight, self.frame.size.width - separatorInset, separatorHeight);

    CGRect frame = self.selectedBackgroundView.frame;
    frame.origin.y = true ? -1 : 0;
    frame.size.height = self.frame.size.height + 1;
    self.selectedBackgroundView.frame = frame;
    
    CGFloat leftPadding = TGIsPad() ? 45.0f : 34.0f;
    if (self.editing)
        leftPadding += 2;
    
    int avatarWidth = 5 + 40;
    if (TGIsPad())
        avatarWidth += 8;

    CGRect avatarFrame = CGRectMake(leftPadding, 4.0f, 40, 40);
    if (TGIsPad())
        avatarFrame = CGRectMake(leftPadding + 19, 5.0f, 45, 45);
    
    if (!CGRectEqualToRect(_avatarView.frame, avatarFrame))
        _avatarView.frame = avatarFrame;
    
    leftPadding = CGRectGetMaxX(avatarFrame) + 12.0f;
    
    _nameLabel.frame = CGRectMake(leftPadding, 5.0f, _nameLabel.frame.size.width, _nameLabel.frame.size.height);
    _subLabel.frame = CGRectMake(leftPadding, 26.0f, _subLabel.frame.size.width, _subLabel.frame.size.height);
    
    _dateLabel.frame = CGRectMake(self.frame.size.width - _dateLabel.frame.size.width - 48.0f, 16.0f, _dateLabel.frame.size.width, _dateLabel.frame.size.height);
    
    _infoButton.frame = CGRectMake(self.frame.size.width - 48.0f, 0, 48.0f, 48.0f);
}

- (void)setIsLastCell:(bool)isLastCell {
    if (_isLastCell != isLastCell) {
        _isLastCell = isLastCell;
        [self setNeedsLayout];
    }
}

@end
