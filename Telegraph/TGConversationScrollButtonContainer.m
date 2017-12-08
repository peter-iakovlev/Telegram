#import "TGConversationScrollButtonContainer.h"

#import "TGAnimationUtils.h"

@implementation TGConversationScrollButtonContainer

- (instancetype)initWithFrame:(CGRect)__unused frame {
    CGSize buttonSize = CGSizeMake(38.0f, 38.0f);
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height * 2.0 + 12.0)];
    if (self != nil) {
        _downButton = [[TGConversationScrollButton alloc] initWithMentions:false];
        _downButton.modernHighlight = false;
        
        _mentionsButton = [[TGConversationScrollButton alloc] initWithMentions:true];
        _mentionsButton.modernHighlight = false;
        
        _downButton.alpha = 0.0f;
        _mentionsButton.alpha = 0.0f;
        
        [self addSubview:_downButton];
        [self addSubview:_mentionsButton];
        
        [_downButton addTarget:self action:@selector(downPressed) forControlEvents:UIControlEventTouchUpInside];
        [_mentionsButton addTarget:self action:@selector(mentionsPressed) forControlEvents:UIControlEventTouchUpInside];
        [_mentionsButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mentionsLongPressed:)]];
        
        [self updateLayoutAnimated:false];
    }
    return self;
}

- (void)setDisplayDownButton:(bool)displayDownButton {
    if (displayDownButton != _displayDownButton) {
        _displayDownButton = displayDownButton;
        [self updateLayoutAnimated:true];
    }
}

- (void)setUnseenMentionCount:(int32_t)unseenMentionCount {
    if (_unseenMentionCount != unseenMentionCount) {
        _unseenMentionCount = unseenMentionCount;
        [_mentionsButton setBadgeCount:unseenMentionCount];
        [self updateLayoutAnimated:true];
    }
}

- (void)setUnreadMessageCount:(int32_t)unreadMessageCount {
    if (_unreadMessageCount != unreadMessageCount) {
        _unreadMessageCount = unreadMessageCount;
        [_downButton setBadgeCount:unreadMessageCount];
        [self updateLayoutAnimated:true];
    }
}

- (void)updateLayoutAnimated:(bool)animated {
    CGSize buttonSize = CGSizeMake(38.0f, 38.0f);
    CGSize completeSize = CGSizeMake(buttonSize.width, buttonSize.height * 2.0 + 12.0);
    CGFloat mentionsOffset = 0.0f;
    
    if (_displayDownButton) {
        mentionsOffset = buttonSize.height + 14.0f;
        if (_unreadMessageCount > 0) {
            mentionsOffset += 4.0f;
        }
        if (self.downButton.alpha <= FLT_EPSILON) {
            self.downButton.alpha = 1.0f;
            if (animated) {
                [self.downButton.layer animateAlphaFrom:0.0f to:1.0f duration:0.2 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
            }
        }
    } else {
        if (self.downButton.alpha > FLT_EPSILON) {
            self.downButton.alpha = 0.0f;
            if (animated) {
                [self.downButton.layer animateAlphaFrom:1.0f to:0.0f duration:0.2 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
            }
        }
    }
    
    if (_unseenMentionCount != 0) {
        if (self.mentionsButton.alpha <= FLT_EPSILON) {
            self.mentionsButton.alpha = 1.0f;
            if (animated) {
                [self.mentionsButton.layer animateAlphaFrom:0.0f to:1.0f duration:0.2 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
            }
        }
    } else {
        if (self.mentionsButton.alpha > FLT_EPSILON) {
            self.mentionsButton.alpha = 0.0f;
            if (animated) {
                [self.mentionsButton.layer animateAlphaFrom:1.0f to:0.0f duration:0.2 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
            }
        }
    }
    
    CGRect downFrame = CGRectMake(0.0, completeSize.height - buttonSize.height, buttonSize.width, buttonSize.height);
    CGPoint downPosition = CGPointMake(CGRectGetMidX(downFrame), CGRectGetMidY(downFrame));
    
    if (!CGPointEqualToPoint(self.downButton.center, downPosition)) {
        CGPoint previousPosition = self.downButton.center;
        self.downButton.center = downPosition;
        if (animated) {
            [self.downButton.layer animatePositionFrom:previousPosition to:downPosition duration:0.2 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
        }
    }
    
    CGRect mentionsFrame = CGRectMake(0.0, completeSize.height - buttonSize.height - mentionsOffset, buttonSize.width, buttonSize.height);
    CGPoint mentionsPosition = CGPointMake(CGRectGetMidX(mentionsFrame), CGRectGetMidY(mentionsFrame));
    
    if (!CGPointEqualToPoint(self.mentionsButton.center, mentionsPosition)) {
        CGPoint previousPosition = self.mentionsButton.center;
        self.mentionsButton.center = mentionsPosition;
        if (animated) {
            [self.mentionsButton.layer animatePositionFrom:previousPosition to:mentionsPosition duration:0.2 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
        }
    }
}

- (void)downPressed {
    if (_onDown) {
        _onDown();
    }
}

- (void)mentionsPressed {
    if (_onMentions) {
        _onMentions();
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == _downButton || result == _mentionsButton) {
        return result;
    }
    return nil;
}

- (void)mentionsLongPressed:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (_onMentionsMenu) {
            _onMentionsMenu();
        }
    }
}

@end
