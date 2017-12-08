#import "TGLiveLocationTitlePanel.h"

#import <LegacyComponents/LegacyComponents.h>
#import <LegacyComponents/TGLocationWavesView.h>

#import <LegacyComponents/TGLocationViewController.h>

#import "TGTelegraph.h"

@interface TGLiveLocationTitlePanel () {
    UIImageView *_pinView;
    TGLocationWavesView *_wavesView;
    
    UILabel *_titleLabel;
    UILabel *_participantsLabel;
    TGModernButton *_closeButton;
    UIView *_separatorView;
}

@end

@implementation TGLiveLocationTitlePanel

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 37.0f)];
    if (self != nil) {
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        
        _pinView = [[UIImageView alloc] initWithImage:TGTintedImage(TGImageNamed(@"LiveLocationTitlePin"), TGAccentColor())];
        _pinView.contentMode = UIViewContentModeCenter;
        _pinView.frame = CGRectMake(0.0f, 0.0f, 48.0f, 48.0f);
        [self addSubview:_pinView];
        
        _wavesView = [[TGLocationWavesView alloc] init];
        _wavesView.color = TGAccentColor();
        [self addSubview:_wavesView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGSystemFontOfSize(13.0f);
        _titleLabel.text = TGLocalized(@"Conversation.LiveLocation");
        _titleLabel.numberOfLines = 1;
        _titleLabel.userInteractionEnabled = false;
        [self addSubview:_titleLabel];
        
        _participantsLabel = [[UILabel alloc] init];
        _participantsLabel.backgroundColor = [UIColor clearColor];
        _participantsLabel.textColor = UIColorRGB(0x8d8e93);
        _participantsLabel.font = TGSystemFontOfSize(10.0f);
        _participantsLabel.text = nil;
        _participantsLabel.numberOfLines = 1;
        _participantsLabel.userInteractionEnabled = false;
        [self addSubview:_participantsLabel];
        
        _closeButton = [[TGModernButton alloc] init];
        _closeButton.adjustsImageWhenHighlighted = false;
        [_closeButton setImage:TGImageNamed(@"MusicPlayerMinimizedClose.png") forState:UIControlStateNormal];
        _closeButton.extendedEdgeInsets = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_separatorView];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
    }
    return self;
}

- (void)setLiveLocations:(NSArray *)liveLocations
{
    bool selfSharing = false;
    TGUser *otherUser = nil;
    for (TGLiveLocation *liveLocation in liveLocations)
    {
        if (!selfSharing && [liveLocation peerId] == TGTelegraphInstance.clientUserId)
            selfSharing = true;
        
        if ([liveLocation peerId] != TGTelegraphInstance.clientUserId && otherUser == nil && [liveLocation.peer isKindOfClass:[TGUser class]])
            otherUser = (TGUser *)liveLocation.peer;
    }
    
    NSAttributedString *string;
    if (selfSharing)
    {
        _pinView.image = TGTintedImage(TGImageNamed(@"LiveLocationTitlePin"), TGAccentColor());
        _wavesView.hidden = false;
        [_wavesView start];
        
        if (liveLocations.count == 1)
        {
            string = [[NSAttributedString alloc] initWithString:TGLocalized(@"Conversation.LiveLocationYou") attributes:@{ NSFontAttributeName: _participantsLabel.font, NSForegroundColorAttributeName: TGAccentColor() }];
        }
        else
        {
            NSString *secondPart = nil;
            if (liveLocations.count == 2)
            {
                secondPart = otherUser.firstName;
            }
            else
            {
                NSInteger count = liveLocations.count - 1;
                NSString *formatPrefix = [TGStringUtils integerValueFormat:@"Conversation.LiveLocationMembersCount_" value:count];
                secondPart = [[NSString alloc] initWithFormat:TGLocalized(formatPrefix), [[NSString alloc] initWithFormat:@"%ld", count]];
            }
            
            NSString *finalString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.LiveLocationYouAnd"), secondPart];
            NSInteger youStart = -1;
            NSInteger youEnd = -1;
            for (int i = 0; i < (int)finalString.length; i++)
            {
                unichar c = [finalString characterAtIndex:i];
                if (c == '*')
                {
                    if (youStart == -1)
                    {
                        youStart = i;
                    }
                    else
                    {
                        if (youEnd == -1)
                        {
                            youEnd = i;
                            break;
                        }
                    }
                }
            }
            finalString = [finalString stringByReplacingOccurrencesOfString:@"*" withString:@""];
            NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:finalString attributes:@{ NSFontAttributeName: _participantsLabel.font, NSForegroundColorAttributeName: UIColorRGB(0x8d8e93) }];
            if (youStart != -1 && youEnd != -1)
            {
                NSRange youRange = NSMakeRange(youStart, youEnd - youStart - 1);
                [mutableString addAttribute:NSForegroundColorAttributeName value:TGAccentColor() range:youRange];
            }
            string = mutableString;
        }
    }
    else
    {
        _pinView.image = TGTintedImage(TGImageNamed(@"LiveLocationTitleIcon"), TGAccentColor());
        [_wavesView stop];
        _wavesView.hidden = true;
        
        if (liveLocations.count == 1)
        {
            string = [[NSAttributedString alloc] initWithString:[otherUser displayName] attributes:@{ NSFontAttributeName: _participantsLabel.font, NSForegroundColorAttributeName: UIColorRGB(0x8d8e93) }];
        }
        else
        {
            NSString *formatPrefix = [TGStringUtils integerValueFormat:@"Conversation.LiveLocationMembersCount_" value:liveLocations.count];
            NSString *countString = [[NSString alloc] initWithFormat:TGLocalized(formatPrefix), [[NSString alloc] initWithFormat:@"%ld", liveLocations.count]];
            string = [[NSAttributedString alloc] initWithString:countString attributes:@{ NSFontAttributeName: _participantsLabel.font, NSForegroundColorAttributeName: UIColorRGB(0x8d8e93) }];
        }
    }
    
    _participantsLabel.attributedText = string;
    [self layoutSubviews];
}

- (void)setSessions:(NSArray *)sessions
{
    [_wavesView start];
    
    NSString *string = nil;
    if (sessions.count == 1)
    {
        id peer = [[sessions firstObject] peer];
        NSString *name = [peer isKindOfClass:[TGUser class]] ? ((TGUser *)peer).displayName : ((TGConversation *)peer).chatTitle;
        string = [[NSString alloc] initWithFormat:TGLocalized(@"DialogList.LiveLocationSharingTo"), name];
    }
    else
    {
        NSString *formatPrefix = [TGStringUtils integerValueFormat:@"DialogList.LiveLocationChatsCount_" value:sessions.count];
        string = [[NSString alloc] initWithFormat:TGLocalized(formatPrefix), [[NSString alloc] initWithFormat:@"%ld", sessions.count]];
    }
    
    _participantsLabel.text = string;
    [self layoutSubviews];
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_tapped) {
            _tapped();
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [super hitTest:point withEvent:event];
}

- (void)closeButtonPressed
{
    if (_closed) {
        _closed();
    }
}

- (UIButton *)closeButton
{
    return _closeButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _pinView.frame = CGRectMake(3.0f + self.safeAreaInset.left, -5.0f, _pinView.frame.size.width, _pinView.frame.size.height);
    _wavesView.frame = CGRectMake(3.0f + self.safeAreaInset.left, -5.0f, 48.0f, 48.0f);
    
    CGFloat maxWidth = self.frame.size.width - 60.0f;
    CGSize labelSize = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(maxWidth, self.frame.size.height)];
    labelSize.width = MIN(maxWidth, CGCeil(labelSize.width));
    labelSize.height = CGCeil(labelSize.height);
    
    _titleLabel.frame = CGRectMake(CGFloor((self.frame.size.width - labelSize.width) / 2.0f), 3.0f, labelSize.width, labelSize.height);
    
    labelSize = [_participantsLabel.text sizeWithFont:_participantsLabel.font constrainedToSize:CGSizeMake(maxWidth, self.frame.size.height)];
    labelSize.width = MIN(maxWidth, CGCeil(labelSize.width));
    labelSize.height = CGCeil(labelSize.height);
    _participantsLabel.frame = CGRectMake(CGFloor((self.frame.size.width - labelSize.width) / 2.0f), 19.0f + TGScreenPixel, labelSize.width, labelSize.height);
    
    _closeButton.frame = CGRectMake(self.frame.size.width - 44.0f - self.safeAreaInset.right, TGRetinaPixel, 44.0f, 36.0f);
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
}

@end
