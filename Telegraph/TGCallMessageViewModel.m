#import "TGCallMessageViewModel.h"

#import "TGFont.h"
#import "TGDateUtils.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGMessage.h"
#import "TGCallDiscardReason.h"

#import "TGModernImageViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGModernButtonViewModel.h"
#import "TGModernButtonView.h"
#import "TGModernFlatteningViewModel.h"

#import "TGDoubleTapGestureRecognizer.h"

@interface TGCallMessageViewModel ()
{
    int32_t _callForMessageId;
    
    TGModernImageViewModel *_iconModel;
    TGModernTextViewModel *_typeModel;
    TGModernTextViewModel *_timeModel;
    TGModernButtonViewModel *_callButtonModel;
}
@end

@implementation TGCallMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message actionMedia:(TGActionMediaAttachment *)actionMedia authorPeer:(id)__unused authorPeer additionalUsers:(NSArray *)__unused additionalUsers context:(TGModernViewContext *)context
{
    _inhibitChecks = true;
    self = [super initWithMessage:message authorPeer:nil viaUser:nil context:context];
    if (self != nil)
    {
        _callForMessageId = message.mid;

        static UIColor *incomingDetailColor = nil;
        static UIColor *outgoingDetailColor = nil;
        static UIImage *incomingCallIcon = nil;
        static UIImage *outgoingCallIcon = nil;
        
        static UIImage *incomingGreenIcon = nil;
        static UIImage *incomingRedIcon = nil;
        static UIImage *outgoingGreenIcon = nil;
        static UIImage *outgoingRedIcon = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            incomingDetailColor = UIColorRGB(0x999999);
            outgoingDetailColor = UIColorRGB(0x2da32e);
            incomingCallIcon = TGTintedImage([UIImage imageNamed:@"TabIconCalls"], TGAccentColor());
            outgoingCallIcon = TGTintedImage([UIImage imageNamed:@"TabIconCalls"], UIColorRGB(0x3fc33b));
            
            incomingGreenIcon = TGTintedImage([UIImage imageNamed:@"MessageCallIncomingIcon"], UIColorRGB(0x36c033));
            incomingRedIcon = TGTintedImage([UIImage imageNamed:@"MessageCallIncomingIcon"], UIColorRGB(0xff4747));
            
            outgoingGreenIcon = TGTintedImage([UIImage imageNamed:@"MessageCallOutgoingIcon"], UIColorRGB(0x36c033));
            outgoingRedIcon = TGTintedImage([UIImage imageNamed:@"MessageCallOutgoingIcon"], UIColorRGB(0xff4747));
        });
        
        bool outgoing = message.outgoing;
        int reason = [actionMedia.actionData[@"reason"] intValue];
        bool missed = reason == TGCallDiscardReasonMissed || reason == TGCallDiscardReasonBusy;
        
        NSString *type = TGLocalized(missed ? (outgoing ? @"Notification.CallCanceled" : @"Notification.CallMissed") : (outgoing ? @"Notification.CallOutgoing" : @"Notification.CallIncoming"));
        
        int callDuration = [actionMedia.actionData[@"duration"] intValue];
        NSString *duration = missed || callDuration < 1 ? nil : [TGStringUtils stringForCallDurationSeconds:callDuration];
        NSString *time = [TGDateUtils stringForShortTime:(int)message.date daytimeVariant:NULL];
        
        if (duration != nil)
            time = [NSString stringWithFormat:TGLocalized(@"Notification.CallFormat"), time, duration];
        
        _typeModel = [[TGModernTextViewModel alloc] initWithText:type font:TGCoreTextMediumFontOfSize(16.0f)];
        _typeModel.maxNumberOfLines = 1;
        _typeModel.textColor = [UIColor blackColor];
        [_contentModel addSubmodel:_typeModel];
        
        _timeModel = [[TGModernTextViewModel alloc] initWithText:time font:TGCoreTextSystemFontOfSize(13.0f)];
        _timeModel.maxNumberOfLines = 1;
        _timeModel.textColor = _incomingAppearance ? incomingDetailColor : outgoingDetailColor;
        [_contentModel addSubmodel:_timeModel];
        
        _iconModel = [[TGModernImageViewModel alloc] init];
        _iconModel.image = outgoing ? (missed ? outgoingRedIcon : outgoingGreenIcon) : (missed ? incomingRedIcon : incomingGreenIcon);
        [_contentModel addSubmodel:_iconModel];
        
        __weak TGCallMessageViewModel *weakSelf = self;
        _callButtonModel = [[TGModernButtonViewModel alloc] init];
        _callButtonModel.pressed = ^
        {
            __strong TGCallMessageViewModel *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf callPressed];
        };
        _callButtonModel.image = _incomingAppearance ? incomingCallIcon : outgoingCallIcon;
        _callButtonModel.modernHighlight = true;
        [self addSubmodel:_callButtonModel];
        
        [_contentModel removeSubmodel:(TGModernViewModel *)_dateModel viewStorage:nil];
    }
    return self;
}

- (void)callPressed
{
    [_context.companionHandle requestAction:@"callRequested" options:@{@"mid": @(_callForMessageId), @"immediate": @true}];
}

- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    [self callPressed];
}

- (void)layoutContentForHeaderHeight:(CGFloat)__unused headerHeight
{
    _typeModel.frame = CGRectMake(2.0f, 6.0f, _typeModel.frame.size.width, _typeModel.frame.size.height);
    _timeModel.frame = CGRectMake(16.0f, 30.0f, _timeModel.frame.size.width, _timeModel.frame.size.height);
    _iconModel.frame = CGRectMake(3.0f, 36.5f, 9.0f, 9.0f);
    
    CGFloat typeWidth = _typeModel.frame.size.width;
    CGFloat timeWidth = _timeModel.frame.size.width;
    CGFloat width = MIN(typeWidth, timeWidth) + fabs(typeWidth - timeWidth);
    width = MAX(110, width);
    _callButtonModel.frame = CGRectMake(_contentModel.frame.origin.x + width + 18.0f, _contentModel.frame.origin.y + 4.0f, 50.0f, 50.0f);
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)__unused infoWidth
{
    CGSize typeContainerSize = CGSizeMake(MIN(200, containerSize.width - 18), containerSize.height);
    bool updateTypeContents = [_typeModel layoutNeedsUpdatingForContainerSize:typeContainerSize additionalTrailingWidth:0.0f layoutFlags:0];
    if (updateTypeContents)
        [_typeModel layoutForContainerSize:typeContainerSize];
    
    CGSize timeContainerSize = CGSizeMake(MAX(_typeModel.frame.size.width, containerSize.width - 30.0f), containerSize.height);
    bool updateTimeContents = [_timeModel layoutNeedsUpdatingForContainerSize:timeContainerSize additionalTrailingWidth:0.0f layoutFlags:0];
    if (updateTimeContents)
        [_timeModel layoutForContainerSize:timeContainerSize];
    
    CGFloat typeWidth = _typeModel.frame.size.width;
    CGFloat timeWidth = _timeModel.frame.size.width;
    CGFloat width = MIN(typeWidth, timeWidth) + fabs(typeWidth - timeWidth);
    width = MAX(110, width);
    
    *needsContentsUpdate = updateTypeContents || updateTimeContents;
    
    return CGSizeMake(width + 60.0f, 52.0f);
}

@end
