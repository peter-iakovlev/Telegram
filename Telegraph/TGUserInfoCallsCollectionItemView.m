#import "TGUserInfoCallsCollectionItemView.h"

#import "TGStringUtils.h"
#import "TGDateUtils.h"
#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGMessage.h"
#import "TGCallDiscardReason.h"

@interface TGUserInfoCallView : UIView
{
    UILabel *_timeLabel;
    UILabel *_typeLabel;
    UILabel *_durationLabel;
}

- (instancetype)initWithMessage:(TGMessage *)message;

@end


@interface TGUserInfoCallsCollectionItemView ()
{
    CALayer *_separatorLayer;
    
    UILabel *_dateLabel;
    NSArray *_callViews;
}
@end

@implementation TGUserInfoCallsCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.backgroundView.layer addSublayer:_separatorLayer];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = TGSystemFontOfSize(14.0f);
        _dateLabel.textColor = [UIColor blackColor];
        [self addSubview:_dateLabel];
    }
    return self;
}

- (void)setCallMessages:(NSArray *)callMessages
{
    if (_callViews.count > 0)
    {
        for (TGUserInfoCallView *view in _callViews)
            [view removeFromSuperview];
        
        _callViews = nil;
    }
    
    _dateLabel.text = (callMessages.count == 0) ? nil : [TGDateUtils stringForCallsListDate:(int)[(TGMessage *)callMessages.firstObject date]];
    [_dateLabel sizeToFit];
    
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (TGMessage *message in callMessages)
    {
        TGUserInfoCallView *callView = [[TGUserInfoCallView alloc] initWithMessage:message];
        [self addSubview:callView];
        
        [views addObject:callView];
    }
    _callViews = views;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorLayer.frame = CGRectMake(35.0f, bounds.size.height - separatorHeight, bounds.size.width - 35.0f, separatorHeight);
    
    _dateLabel.frame = CGRectMake(36, 0, _dateLabel.frame.size.width, _dateLabel.frame.size.height);
    
    [_callViews enumerateObjectsUsingBlock:^(TGUserInfoCallView *callView, NSUInteger index, __unused BOOL *stop)
    {
        callView.frame = CGRectMake(0, 26.0f + 26.0f * index, self.frame.size.width, 26.0f);
    }];
}

@end


@implementation TGUserInfoCallView

- (instancetype)initWithMessage:(TGMessage *)message
{
    self = [super init];
    if (self != nil)
    {
        bool outgoing = message.outgoing;
        int reason = [message.actionInfo.actionData[@"reason"] intValue];
        bool missed = reason == TGCallDiscardReasonMissed || reason == TGCallDiscardReasonBusy;
        
        NSString *time = [TGDateUtils stringForShortTime:(int)message.date];
        NSString *type = TGLocalized(missed ? (outgoing ? @"Notification.CallCanceled" : @"Notification.CallMissed") : (outgoing ? @"Notification.CallOutgoing" : @"Notification.CallIncoming"));
        int callDuration = [message.actionInfo.actionData[@"duration"] intValue];
        NSString *duration = missed || callDuration < 1 ? nil : [TGStringUtils stringForCallDurationSeconds:callDuration];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = TGSystemFontOfSize(12.0f);
        _timeLabel.text = time;
        _timeLabel.textColor = [UIColor blackColor];
        [self addSubview:_timeLabel];
        [_timeLabel sizeToFit];
        
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.font = TGMediumSystemFontOfSize(12.0f);
        _typeLabel.text = type;
        _typeLabel.textColor = [UIColor blackColor];
        [self addSubview:_typeLabel];
        [_typeLabel sizeToFit];
        
        if (duration != nil)
        {
            _durationLabel = [[UILabel alloc] init];
            _durationLabel.backgroundColor = [UIColor clearColor];
            _durationLabel.font = TGSystemFontOfSize(12.0f);
            _durationLabel.text = duration;
            _durationLabel.textColor = [UIColor blackColor];
            [self addSubview:_durationLabel];
            [_durationLabel sizeToFit];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    static CGFloat x1 = 0;
    static CGFloat x2 = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize screenSize = TGScreenSize();
        if ((int)screenSize.width == 320)
        {
            x1 = 100.0f;
            x2 = 230.0f;
        }
        else
        {
            x1 = 110.0f;
            x2 = 250.0f;
        }
    });
    
    _timeLabel.frame = CGRectMake(36.0f, 0.0f, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
    _typeLabel.frame = CGRectMake(x1, 0.0f, _typeLabel.frame.size.width, _typeLabel.frame.size.height);
    _durationLabel.frame = CGRectMake(x2, 0.0f, _durationLabel.frame.size.width, _durationLabel.frame.size.height);
}

@end
