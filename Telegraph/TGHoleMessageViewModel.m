#import "TGHoleMessageViewModel.h"

#import "TGUser.h"
#import "TGMessage.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

#import "TGModernImageViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernTextViewModel.h"

#import "TGModernDataImageViewModel.h"
#import "TGModernDataImageView.h"

#import "TGModernRemoteImageView.h"

#import "TGReusableLabel.h"
#import "TGDoubleTapGestureRecognizer.h"

#import "TGStringUtils.h"

@interface TGHoleMessageViewModel () <UIGestureRecognizerDelegate> {
    TGModernImageViewModel *_backgroundModel;
    TGModernFlatteningViewModel *_contentModel;
    TGModernTextViewModel *_textModel;
    
    UITapGestureRecognizer *_tapRecognizer;
    
    CGSize _lastContainerSize;
    
    TGMessage *_message;
}

@end

@implementation TGHoleMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message context:(TGModernViewContext *)context {
    self = [super initWithAuthorPeer:nil context:context];
    if (self != nil) {
        _mid = message.mid;
        _message = message;
        
        _backgroundModel = [[TGModernImageViewModel alloc] initWithImage:[[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackground]];
        _backgroundModel.skipDrawInContext = true;
        [self addSubmodel:_backgroundModel];
        
        _contentModel = [[TGModernFlatteningViewModel alloc] initWithContext:_context];
        _contentModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_contentModel];
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:[self actionTextForMessage:message] font:[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleFont]];
        _textModel.textColor = [UIColor whiteColor];
        _textModel.alignment = NSTextAlignmentCenter;
        [_contentModel addSubmodel:_textModel];
    }
    return self;
}

- (NSString *)actionTextForMessage:(TGMessage *)message {
    NSString *actionText = @"";
    if (message.hole != nil) {
        actionText = TGLocalized(@"Channel.NotificationLoading");
#ifdef DEBUG
        actionText = [actionText stringByAppendingString:[[NSString alloc] initWithFormat:@" (%d ... %d)", message.hole.minId, message.hole.maxId]];
#endif
    } else if (message.group != nil) {
        actionText = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"Channel.NotificationComments_" value:message.group.count]), [[NSString alloc] initWithFormat:@"%d", (int)message.group.count]];
#ifdef DEBUG
        actionText = [actionText stringByAppendingString:[[NSString alloc] initWithFormat:@" (%d ... %d)", message.group.minId, message.group.maxId]];
#endif
    }
    return actionText;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    _mid = message.mid;
    _message = message;
    
    [_textModel setText:[self actionTextForMessage:message]];
    
    [self layoutForContainerSize:_lastContainerSize];
    
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
}

- (CGRect)effectiveContentFrame
{
    return _backgroundModel.frame;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    [_backgroundModel bindViewToContainer:container viewStorage:viewStorage];
    [_backgroundModel boundView].frame = CGRectOffset([_backgroundModel boundView].frame, itemPosition.x, itemPosition.y);
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    
    UIView *backgroundView = [_backgroundModel boundView];
    [backgroundView addGestureRecognizer:_tapRecognizer];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    UIView *backgroundView = [_backgroundModel boundView];
    [backgroundView removeGestureRecognizer:_tapRecognizer];
    _tapRecognizer = nil;
    
    [super unbindView:viewStorage];
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_message.group != nil) {
            [_context.companionHandle requestAction:@"openMessageGroup" options:@{@"group": _message.group}];
        }
        
        /*CGPoint point = [recognizer locationInView:[_contentModel boundView]];
        NSString *linkCandidate = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL];
        
        if (recognizer.longTapped || recognizer.doubleTapped)
            [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
        else if (linkCandidate != nil)
            [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": linkCandidate}];*/
    }
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    _lastContainerSize = containerSize;
    if ([_textModel layoutNeedsUpdatingForContainerSize:containerSize]) {
        [_contentModel setNeedsSubmodelContentsUpdate];
        [_textModel layoutForContainerSize:CGSizeMake(containerSize.width - 30.0f, containerSize.height)];
    }
    
    CGSize textSize = _textModel.frame.size;
    
    CGFloat backgroundWidth = MAX(60.0f, textSize.width + 14.0f);
    CGRect backgroundFrame = CGRectMake(CGFloor((containerSize.width - backgroundWidth) / 2.0f), 3.0f, backgroundWidth, MAX(21.0f, textSize.height + 4.0f));
    _backgroundModel.frame = backgroundFrame;
    
    _contentModel.frame = CGRectMake(backgroundFrame.origin.x + 7.0f - 2.0f, 1.0f - 2.0f, backgroundWidth - 6.0f + 4.0f, textSize.height + 2.0f + 4.0f);
    _textModel.frame = CGRectMake(2.0f, 3.0f, textSize.width, textSize.height);
    
    self.frame = CGRectMake(0.0f, 0.0f, containerSize.width, backgroundFrame.size.height + 6.0f);
    
    [_contentModel updateSubmodelContentsIfNeeded];
    
    [super layoutForContainerSize:containerSize];
}

@end
