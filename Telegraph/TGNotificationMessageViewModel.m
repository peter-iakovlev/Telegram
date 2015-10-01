#import "TGNotificationMessageViewModel.h"

#import "TGUser.h"
#import "TGConversation.h"
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

#import "TGPeerIdAdapter.h"

@interface TGNotificationMessageViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate>
{
    TGModernImageViewModel *_backgroundModel;
    TGModernFlatteningViewModel *_contentModel;
    TGModernTextViewModel *_textModel;
    TGModernDataImageViewModel *_imageModel;
    
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    TGDoubleTapGestureRecognizer *_boundImageTapRecognizer;
}

@end

@implementation TGNotificationMessageViewModel

static TGUser *findUserInArray(int32_t uid, NSArray *array)
{
    for (TGUser *user in array)
    {
        if (user.uid == uid)
            return user;
    }
    
    return nil;
}

- (instancetype)initWithMessage:(TGMessage *)message actionMedia:(TGActionMediaAttachment *)actionMedia authorPeer:(id)authorPeer additionalUsers:(NSArray *)additionalUsers context:(TGModernViewContext *)context
{
    self = [super initWithAuthorPeer:nil context:context];
    if (self != nil)
    {
        _mid = message.mid;
        
        _backgroundModel = [[TGModernImageViewModel alloc] initWithImage:[[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackground]];
        _backgroundModel.skipDrawInContext = true;
        [self addSubmodel:_backgroundModel];
        
        _contentModel = [[TGModernFlatteningViewModel alloc] initWithContext:_context];
        _contentModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_contentModel];
        
        NSString *actionText = nil;
        
        NSArray *additionalAttributes = nil;
        NSArray *textCheckingResults = nil;
        
        NSString *authorTitle = @"";
        NSString *authorShortTitle = @"";
        int32_t authorUid = 0;
        if ([authorPeer isKindOfClass:[TGUser class]]) {
            authorTitle = ((TGUser *)authorPeer).displayName;
            authorShortTitle = ((TGUser *)authorPeer).displayFirstName;
            authorUid = ((TGUser *)authorPeer).uid;
        } else if ([authorPeer isKindOfClass:[TGConversation class]]) {
            authorTitle = ((TGConversation *)authorPeer).chatTitle;
            authorShortTitle = authorTitle;
        }
        
        switch (actionMedia.actionType)
        {
            case TGMessageActionChatEditTitle:
            {
                NSString *authorName = authorTitle;
                NSString *formatString = nil;
                NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                if (TGPeerIdIsChannel(message.cid)) {
                    formatString = TGLocalizedStatic(@"Channel.MessageTitleUpdated");
                    actionText = [[NSString alloc] initWithFormat:formatString, actionMedia.actionData[@"title"]];
                } else {
                    formatString = TGLocalizedStatic(@"Notification.ChangedGroupName");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionMedia.actionData[@"title"]];
                    formatNameRange = [formatString rangeOfString:@"%@"];
                }
                
                if (formatNameRange.location != NSNotFound && authorUid != 0)
                {
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                    additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                    textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                }
                
                break;
            }
            case TGMessageActionChatAddMember:
            case TGMessageActionChatDeleteMember:
            {
                NSString *authorName = authorTitle;
                TGUser *user = findUserInArray([actionMedia.actionData[@"uid"] intValue], additionalUsers);
                
                if (user.uid == authorUid)
                {
                    NSString *formatString = actionMedia.actionType == TGMessageActionChatAddMember ? TGLocalizedStatic(@"Notification.JoinedChat") : TGLocalizedStatic(@"Notification.LeftChat");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", user.uid]]], nil];
                    }
                }
                else
                {
                    NSString *userName = user.displayName;
                    NSString *formatString = actionMedia.actionType == TGMessageActionChatAddMember ? TGLocalizedStatic(@"Notification.Invited") : TGLocalizedStatic(@"Notification.Kicked");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName, userName];
                    
                    NSRange formatNameRangeFirst = [formatString rangeOfString:@"%@"];
                    NSRange formatNameRangeSecond = formatNameRangeFirst.location != NSNotFound ? [formatString rangeOfString:@"%@" options:0 range:NSMakeRange(formatNameRangeFirst.location + formatNameRangeFirst.length, formatString.length - (formatNameRangeFirst.location + formatNameRangeFirst.length))] : NSMakeRange(NSNotFound, 0);
                    
                    if (formatNameRangeFirst.location != NSNotFound && formatNameRangeSecond.location != NSNotFound)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange rangeFirst = NSMakeRange(formatNameRangeFirst.location, authorName.length);
                        NSRange rangeSecond = NSMakeRange(rangeFirst.length - formatNameRangeFirst.length + formatNameRangeSecond.location, userName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&rangeFirst objCType:@encode(NSRange)], fontAttributes, [[NSValue alloc] initWithBytes:&rangeSecond objCType:@encode(NSRange)], fontAttributes, nil];
                        
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:rangeFirst URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], [NSTextCheckingResult linkCheckingResultWithRange:rangeSecond URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", user.uid]]], nil];
                    }
                }
                
                break;
            }
            case TGMessageActionJoinedByLink:
            {
                NSString *authorName = authorTitle;
                NSString *formatString = TGLocalizedStatic(@"Notification.JoinedGroupByLink");
                actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionMedia.actionData[@"title"]];
                NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                if (formatNameRange.location != NSNotFound && authorUid != 0)
                {
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                    additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                    
                    textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                }
                break;
            }
            case TGMessageActionCreateChat:
            {
                NSString *authorName = authorTitle;
                NSString *formatString = TGLocalizedStatic(@"Notification.CreatedChatWithTitle");
                actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionMedia.actionData[@"title"]];
                
                NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                if (formatNameRange.location != NSNotFound && authorUid != 0)
                {
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                    additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                    
                    textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                }
                
                break;
            }
            case TGMessageActionChannelCreated:
            {
                actionText = TGLocalized(@"Notification.CreatedChannel");
                
                break;
            }
            case TGMessageActionChannelCommentsStatusChanged:
            {
                actionText = [actionMedia.actionData[@"enabled"] boolValue] ? TGLocalized(@"Channel.NotificationCommentsEnabled") : TGLocalized(@"Channel.NotificationCommentsDisabled");
                break;
            }
            case TGMessageActionChannelInviter:
            {
                NSString *authorName = authorTitle;
                NSString *formatString = TGLocalizedStatic(@"Notification.ChannelInviter");
                if (authorUid == [actionMedia.actionData[@"uid"] intValue]) {
                    actionText = TGLocalized(@"Notification.ChannelInviterSelf");
                } else {
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound && authorUid != 0)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                }
                
                break;
            }
            case TGMessageActionCreateBroadcastList:
            {
                NSString *formatString = TGLocalizedStatic(@"Notification.CreatedBroadcastList");
                actionText = formatString;
                
                break;
            }
            case TGMessageActionChatEditPhoto:
            {
                NSString *authorName = authorTitle;
                
                TGImageMediaAttachment *imageAttachment = actionMedia.actionData[@"photo"];
                CGSize avatarSize = CGSizeMake(70, 70);
                NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:avatarSize resultingSize:&avatarSize];
                
                NSString *formatString = nil;
                NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                
                if (TGPeerIdIsChannel(message.cid)) {
                    formatString = imageUrl != nil ? TGLocalizedStatic(@"Channel.MessagePhotoUpdated") : TGLocalizedStatic(@"Channel.MessagePhotoRemoved");                    
                } else {
                    formatString = imageUrl != nil ? TGLocalizedStatic(@"Notification.ChangedGroupPhoto") : TGLocalizedStatic(@"Notification.RemovedGroupPhoto");
                    formatNameRange = [formatString rangeOfString:@"%@"];
                }

                actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionMedia.actionData[@"title"]];
                
                
                if (formatNameRange.location != NSNotFound && authorUid != 0)
                {
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                    additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                    
                    textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                }
                
                if (imageUrl != nil)
                {
                    NSMutableString *imageUri = [[NSMutableString alloc] initWithString:@"peer-avatar-thumbnail://?"];
                    
                    [imageUri appendFormat:@"legacy-thumbnail-cache-url=%@", imageUrl];
                    [imageUri appendFormat:@"&width=%d&height=%d", 64, 64];
                    
                    _imageModel = [[TGModernDataImageViewModel alloc] initWithUri:imageUri options:nil];
                    [self addSubmodel:_imageModel];
                }
                
                break;
            }
            case TGMessageActionContactRegistered:
            {
                NSString *authorName = authorTitle;
                NSString *formatString = TGLocalizedStatic(@"Notification.Joined");
                actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionMedia.actionData[@"title"]];
                
                NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                if (formatNameRange.location != NSNotFound)
                {
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                    additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                }
                
                break;
            }
            case TGMessageActionUserChangedPhoto:
            {
                NSString *authorName = authorTitle;
                
                NSString *formatString = TGLocalizedStatic(@"Notification.ChangedUserPhoto");
                
                actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionMedia.actionData[@"title"]];
                
                NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                if (formatNameRange.location != NSNotFound)
                {
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                    additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                }
                
                break;
            }
            case TGMessageActionEncryptedChatMessageLifetime:
            {
                int messageLifetime = [actionMedia.actionData[@"messageLifetime"] intValue];
                
                if (messageLifetime == 0)
                {
                    if (message.outgoing)
                        actionText = TGLocalizedStatic(@"Notification.MessageLifetimeRemovedOutgoing");
                    else
                    {
                        NSString *authorName = authorTitle;
                        NSString *formatString = TGLocalizedStatic(@"Notification.MessageLifetimeRemoved");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%1$@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                            NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                            additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        }
                    }
                }
                else
                {
                    NSString *lifetimeString = [TGStringUtils stringForMessageTimerSeconds:messageLifetime];
                    
                    if (message.outgoing)
                        actionText = [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Notification.MessageLifetimeChangedOutgoing"), lifetimeString];
                    else
                    {
                        NSString *authorName = authorTitle;
                        NSString *formatString = TGLocalizedStatic(@"Notification.MessageLifetimeChanged");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName, lifetimeString];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%1$@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                            NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                            additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        }
                    }
                }
                
                break;
            }
            case TGMessageActionEncryptedChatScreenshot:
            case TGMessageActionEncryptedChatMessageScreenshot:
            {
                /*if (message.outgoing)
                    actionText = actionMedia.actionType == TGMessageActionEncryptedChatScreenshot ? TGLocalizedStatic(@"Notification.SecretChatScreenshotOutgoing") : TGLocalizedStatic(@"Notification.SecretChatMessageScreenshotOutgoing");
                else*/
                {
                    NSString *authorName = authorShortTitle;
                    
                    NSString *formatString = TGLocalizedStatic(@"Notification.SecretChatMessageScreenshot");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%1$@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                    }
                }
                
                break;
            }
            default:
                break;
        }
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:actionText font:[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleFont]];
        _textModel.textColor = [UIColor whiteColor];
        _textModel.layoutFlags = TGReusableLabelLayoutMultiline;
        _textModel.alignment = NSTextAlignmentCenter;
        _textModel.additionalAttributes = additionalAttributes;
        _textModel.textCheckingResults = textCheckingResults;
        [_contentModel addSubmodel:_textModel];
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    _mid = message.mid;
    
    [super updateMessage:message viewStorage:viewStorage sizeUpdated:sizeUpdated];
}

- (void)updateMediaVisibility
{
    _imageModel.alpha = [_context isMediaVisibleInMessage:_mid] ? 1.0f : 0.0f;
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
    
    if (_imageModel != nil)
    {
        [_imageModel bindViewToContainer:container viewStorage:viewStorage];
        [_imageModel boundView].frame = CGRectOffset([_imageModel boundView].frame, itemPosition.x, itemPosition.y);
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    _boundDoubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(messageDoubleTapGesture:)];
    _boundDoubleTapRecognizer.delegate = self;
    
    UIView *backgroundView = [_backgroundModel boundView];
    [backgroundView addGestureRecognizer:_boundDoubleTapRecognizer];
    
    if (_imageModel != nil)
    {
        _boundImageTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDoubleTapGesture:)];
        _boundImageTapRecognizer.delegate = self;
        
        UIView *imageView = [_imageModel boundView];
        [imageView addGestureRecognizer:_boundImageTapRecognizer];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    UIView *backgroundView = [_backgroundModel boundView];
    [backgroundView removeGestureRecognizer:_boundDoubleTapRecognizer];
    _boundDoubleTapRecognizer.delegate = nil;
    _boundDoubleTapRecognizer = nil;
    
    if (_imageModel != nil)
    {
        UIView *imageView = [_imageModel boundView];
        [imageView removeGestureRecognizer:_boundImageTapRecognizer];
        _boundImageTapRecognizer.delegate = nil;
        _boundImageTapRecognizer = nil;
    }
    
    [super unbindView:viewStorage];
}

- (void)messageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            CGPoint point = [recognizer locationInView:[_contentModel boundView]];
            NSString *linkCandidate = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:NULL];
            
            if (recognizer.longTapped || recognizer.doubleTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else if (linkCandidate != nil)
                [_context.companionHandle requestAction:@"openLinkRequested" options:@{@"url": linkCandidate}];
        }
    }
}

- (void)imageDoubleTapGesture:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            if (recognizer.longTapped)
                [_context.companionHandle requestAction:@"messageSelectionRequested" options:@{@"mid": @(_mid)}];
            else
                [_context.companionHandle requestAction:@"openMediaRequested" options:@{@"mid": @(_mid)}];
        }
    }
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)__unused point
{
    if (recognizer == _boundImageTapRecognizer)
        return 3;
    else if ([_textModel linkAtPoint:point regionData:nil] != nil)
        return 3;
    
    return false;
}

- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)__unused recognizer
{
    return true;
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [_textModel layoutForContainerSize:CGSizeMake(containerSize.width - 30.0f, containerSize.height)];
    
    CGSize textSize = _textModel.frame.size;
    
    CGFloat backgroundWidth = MAX(60.0f, textSize.width + 14.0f);
    CGRect backgroundFrame = CGRectMake(CGFloor((containerSize.width - backgroundWidth) / 2.0f), 3.0f, backgroundWidth, MAX(21.0f, textSize.height + 4.0f));
    _backgroundModel.frame = backgroundFrame;
    
    _contentModel.frame = CGRectMake(backgroundFrame.origin.x + 7.0f - 2.0f, 1.0f - 2.0f, backgroundWidth - 6.0f + 4.0f, textSize.height + 2.0f + 4.0f);
    _textModel.frame = CGRectMake(2.0f, 3.0f, textSize.width, textSize.height);
    
    if (_imageModel != nil)
    {
        _imageModel.frame = CGRectMake(CGFloor((containerSize.width - 64.0f) / 2.0f), backgroundFrame.origin.y + backgroundFrame.size.height + 3.0f, 64.0f, 64.0f);
    }
    
    self.frame = CGRectMake(0, 0, containerSize.width, backgroundFrame.size.height + 6 + (_imageModel != nil ? 68 : 0));
    
    [_contentModel setNeedsSubmodelContentsUpdate];
    [_contentModel updateSubmodelContentsIfNeeded];
    
    [super layoutForContainerSize:containerSize];
}

- (UIView *)referenceViewForImageTransition
{
    return [_imageModel boundView];
}

@end
