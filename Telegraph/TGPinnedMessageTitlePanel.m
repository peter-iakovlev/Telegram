#import "TGPinnedMessageTitlePanel.h"

#import "TGModenConcersationReplyAssociatedPanel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGPinnedMessageTitlePanel () {
    TGModenConcersationReplyAssociatedPanel *_replyPanel;
    UIView *_separatorView;
}

@end

@implementation TGPinnedMessageTitlePanel

- (instancetype)initWithMessage:(TGMessage *)message {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 51.0f)];
    if (self != nil) {
        _message = message;
        
        _replyPanel = [[TGModenConcersationReplyAssociatedPanel alloc] initWithMessage:message];
        _replyPanel.customTitle = TGLocalized(@"Conversation.PinnedMessage");
        [_replyPanel setTitleFont:TGMediumSystemFontOfSize(14.5f)];
        [_replyPanel setLineInsets:UIEdgeInsetsMake(1.0f, 0.0f, 1.0f + TGRetinaPixel, 0.0)];
        [_replyPanel setSendAreaWidth:14.0f - TGRetinaPixel attachmentAreaWidth:6.0f];
        _replyPanel.largeDismissButton = true;
        __weak TGPinnedMessageTitlePanel *weakSelf = self;
        _replyPanel.pressed = ^{
            __strong TGPinnedMessageTitlePanel *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_tapped) {
                strongSelf->_tapped();
            }
        };
        _replyPanel.dismiss = ^{
            __strong TGPinnedMessageTitlePanel *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.dismiss) {
                strongSelf.dismiss();
            }
        };
        [self addSubview:_replyPanel];
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_separatorView];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message {
    _message = message;
    [_replyPanel updateMessage:message];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
    
    _replyPanel.frame = CGRectMake(0.0f, TGRetinaPixel, self.frame.size.width, 44.0f);
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_tapped) {
            _tapped();
        }
    }
}

@end
