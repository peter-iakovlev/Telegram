#import "TGConversationScrollButton.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGConversationScrollButton () {
    bool _mentions;
    UIImageView *_badgeBackround;
    UILabel *_badgeLabel;
}

@end

@implementation TGConversationScrollButton

- (instancetype)initWithMentions:(bool)mentions {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 38.0f, 38.0f)];
    if (self != nil) {
        _mentions = mentions;
        
        _badgeBackround = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = [UIColor clearColor];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.font = TGSystemFontOfSize(14);
        [self addSubview:_badgeBackround];
        [self addSubview:_badgeLabel];
        
        _badgeLabel.hidden = true;
        _badgeBackround.hidden = true;
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
 
    [self setImage:_mentions ? presentation.images.chatMentionsImage : presentation.images.chatDownImage forState:UIControlStateNormal];
    
    _badgeBackround.image = presentation.images.chatBadgeImage;
    _badgeLabel.textColor = presentation.pallete.accentContrastColor;
}

- (void)setBadgeCount:(NSInteger)badgeCount {
    if (_badgeCount != badgeCount) {
        _badgeCount = badgeCount;
        
        if (badgeCount <= 0) {
            _badgeLabel.hidden = true;
            _badgeBackround.hidden = true;
        } else {
            _badgeLabel.hidden = false;
            _badgeBackround.hidden = false;
            _badgeLabel.text = [NSString stringWithFormat:@"%d", (int)badgeCount];
            [_badgeLabel sizeToFit];
            [self setNeedsLayout];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_badgeLabel.hidden) {
        _badgeLabel.frame = CGRectMake(TGScreenPixelFloor((self.frame.size.width - _badgeLabel.frame.size.width) / 2.0f), -11.0f, _badgeLabel.frame.size.width, _badgeLabel.frame.size.height);
        CGFloat backgroundWidth = MAX(22.0f, _badgeLabel.frame.size.width + 12.0f);
        _badgeBackround.frame = CGRectMake(TGScreenPixelFloor((self.frame.size.width - backgroundWidth) / 2.0f), _badgeLabel.frame.origin.y - 3.0f + TGScreenPixel, backgroundWidth, _badgeBackround.frame.size.height);
    }
}

@end
