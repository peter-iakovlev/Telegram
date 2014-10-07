#import "TGModernConversationTitleActivityIndicator.h"

#import <pop/POP.h>

typedef enum {
    TGModernConversationTitleActivityIndicatorTypeNone = 0,
    TGModernConversationTitleActivityIndicatorTypeTyping = 1,
    TGModernConversationTitleActivityIndicatorTypeAudioRecording = 2,
    TGModernConversationTitleActivityIndicatorTypeUploading = 3
} TGModernConversationTitleActivityIndicatorType;

@interface TGModernConversationTitleActivityIndicator ()
{
    CGFloat _animationValue;
    TGModernConversationTitleActivityIndicatorType _type;
}

@end

@implementation TGModernConversationTitleActivityIndicator

- (void)setNone
{
    [self pop_removeAnimationForKey:@"animationValue"];
    _type = TGModernConversationTitleActivityIndicatorTypeNone;
}

- (void)_beginAnimationIfNeeded
{
    if ([self pop_animationForKey:@"animationValue"] == nil)
    {
        POPBasicAnimation *animation = [POPBasicAnimation animation];
        animation.property = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop)
        {
            prop.readBlock = ^(TGModernConversationTitleActivityIndicator *view, CGFloat values[])
            {
                if (view != nil)
                    values[0] = view->_animationValue;
            };
            
            prop.writeBlock = ^(TGModernConversationTitleActivityIndicator *view, const CGFloat values[])
            {
                if (view != nil)
                    view->_animationValue = values[0];
            };
            
            prop.threshold = 0.01f;
        }];
        animation.fromValue = @(0.0f);
        animation.toValue = @(1.0f);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 0.7;
        animation.repeatForever = true;
        
        [self pop_addAnimation:animation forKey:@"progress"];
    }
}

- (void)setTyping
{
    if (_type != TGModernConversationTitleActivityIndicatorTypeTyping)
    {
        _type = TGModernConversationTitleActivityIndicatorTypeTyping;
        [self setNeedsDisplay];
        [self _beginAnimationIfNeeded];
    }
}

- (void)setAudioRecording
{
    if (_type != TGModernConversationTitleActivityIndicatorTypeAudioRecording)
    {
        _type = TGModernConversationTitleActivityIndicatorTypeAudioRecording;
        [self setNeedsDisplay];
        [self _beginAnimationIfNeeded];
    }
}

- (void)setUploading
{
    if (_type != TGModernConversationTitleActivityIndicatorTypeUploading)
    {
        _type = TGModernConversationTitleActivityIndicatorTypeUploading;
        [self setNeedsDisplay];
        [self _beginAnimationIfNeeded];
    }
}

- (void)drawRect:(CGRect)__unused rect
{
    switch (_type)
    {
        case TGModernConversationTitleActivityIndicatorTypeTyping:
        {
            
            
            break;
        }
        case TGModernConversationTitleActivityIndicatorTypeAudioRecording:
        {
            break;
        }
        case TGModernConversationTitleActivityIndicatorTypeUploading:
        {
            break;
        }
        default:
            break;
    }
}

@end
