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
#import "TGDateUtils.h"

#import "TGPeerIdAdapter.h"

#import "TGTelegraph.h"

#import "TGCurrencyFormatter.h"

#import "TGChannelAdminLogEntry.h"

@interface TGNotificationMessageViewModel () <UIGestureRecognizerDelegate, TGDoubleTapGestureRecognizerDelegate>
{
    TGModernImageViewModel *_backgroundModel;
    TGModernFlatteningViewModel *_contentModel;
    TGModernTextViewModel *_textModel;
    TGModernDataImageViewModel *_imageModel;
    
    UITapGestureRecognizer *_tapRecognizer;
    TGDoubleTapGestureRecognizer *_boundDoubleTapRecognizer;
    TGDoubleTapGestureRecognizer *_boundImageTapRecognizer;
    
    int32_t _navigateToMessageId;
    int32_t _callForMessageId;
    
    TGActionMediaAttachment *_actionMedia;
    TGMessage *_message;
    id _authorPeer;
    NSArray *_additionalUsers;
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

- (bool)setupText {
    id authorPeer = _authorPeer;
    TGActionMediaAttachment *actionMedia = _actionMedia;
    TGMessage *message = _message;
    NSArray *additionalUsers = _additionalUsers;
    
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
            if (TGPeerIdIsChannel(message.cid) && !_context.conversation.isChannelGroup) {
                if (false) {
                    formatString = TGLocalized(@"Group.MessageTitleUpdated");
                    actionText = [[NSString alloc] initWithFormat:formatString, actionMedia.actionData[@"title"]];
                } else {
                    formatString = TGLocalized(@"Channel.MessageTitleUpdated");
                    actionText = [[NSString alloc] initWithFormat:formatString, actionMedia.actionData[@"title"]];
                }
            } else {
                formatString = TGLocalized(@"Notification.ChangedGroupName");
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
            
            if (actionMedia.actionData[@"uids"] != nil) {
                NSArray *uids = actionMedia.actionData[@"uids"];
                
                if (uids.count == 1 && authorUid == [((NSNumber *)uids[0]) intValue]) {
                    NSString *formatBase = TGLocalized(@"Notification.JoinedChat");
                    if (_context.isAdminLog && !_context.adminLogIsGroup) {
                        formatBase = TGLocalized(@"Notification.JoinedChannel");
                    }
                    
                    actionText = [[NSString alloc] initWithFormat:formatBase, authorName];
                    
                    NSRange formatNameRange = [formatBase rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                } else {
                    NSMutableString *subjectNames = [[NSMutableString alloc] init];
                    
                    NSMutableArray *subjectRangesAndUids = [[NSMutableArray alloc] init];
                    
                    for (NSNumber *nUid in uids) {
                        TGUser *user = findUserInArray([nUid intValue], additionalUsers);
                        if (user != nil) {
                            if (subjectNames.length != 0) {
                                [subjectNames appendString:@", "];
                            }
                            
                            [subjectRangesAndUids addObject:@[[NSValue valueWithRange:NSMakeRange(subjectNames.length, user.displayName.length)], @(user.uid)]];
                            [subjectNames appendString:user.displayName];
                        }
                    }
                    
                    NSString *formatString = TGLocalized(@"Notification.Invited");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName, subjectNames];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        
                        NSMutableArray *multipleTextCheckingResults = [[NSMutableArray alloc] init];
                        NSMutableArray *multipleAdditionalAttributes = [[NSMutableArray alloc] init];
                        
                        NSUInteger multipleRangesOffset = formatNameRange.location + formatNameRange.length;
                        
                        {
                            NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                            [multipleAdditionalAttributes addObject:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)]];
                            [multipleAdditionalAttributes addObject:fontAttributes];
                            
                            multipleRangesOffset = formatNameRange.location + authorName.length - formatNameRange.length;
                            
                            [multipleTextCheckingResults addObject:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]]];
                        }
                        
                        NSRange nextFormatNameRange = [formatString rangeOfString:@"%@" options:0 range:NSMakeRange(formatNameRange.location + formatNameRange.length, formatString.length - formatNameRange.location - formatNameRange.length)];
                        
                        if (nextFormatNameRange.location != NSNotFound) {
                            multipleRangesOffset += nextFormatNameRange.location;
                            
                            for (NSArray *record in subjectRangesAndUids) {
                                NSRange range = [(NSValue *)record[0] rangeValue];
                                range.location += multipleRangesOffset;
                                NSNumber *nUid = record[1];
                                
                                [multipleAdditionalAttributes addObject:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)]];
                                [multipleAdditionalAttributes addObject:fontAttributes];
                                
                                [multipleTextCheckingResults addObject:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", [nUid intValue]]]]];
                            }
                        }
                        
                        textCheckingResults = multipleTextCheckingResults;
                        additionalAttributes = multipleAdditionalAttributes;
                    }
                }
            } else {
                TGUser *user = findUserInArray([actionMedia.actionData[@"uid"] intValue], additionalUsers);
                
                if (user.uid == authorUid)
                {
                    NSString *formatBase = TGLocalized(@"Notification.JoinedChat");
                    
                    if (actionMedia.actionType == TGMessageActionChatAddMember) {
                        formatBase = TGLocalized(@"Notification.JoinedChat");
                        if (_context.isAdminLog && !_context.adminLogIsGroup) {
                            formatBase = TGLocalized(@"Notification.JoinedChannel");
                        }
                    } else {
                        formatBase = TGLocalized(@"Notification.LeftChat");
                        if (_context.isAdminLog && !_context.adminLogIsGroup) {
                            formatBase = TGLocalized(@"Notification.LeftChannel");
                        }
                    }
                    
                    NSString *formatString = formatBase;
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
                    NSString *formatString = actionMedia.actionType == TGMessageActionChatAddMember ? TGLocalized(@"Notification.Invited") : TGLocalized(@"Notification.Kicked");
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
            }
            
            break;
        }
        case TGMessageActionJoinedByLink:
        {
            NSString *authorName = authorTitle;
            NSString *formatString = TGLocalized(@"Notification.JoinedGroupByLink");
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
            NSString *formatString = TGLocalized(@"Notification.CreatedChatWithTitle");
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
            actionText = _context.conversation.isChannelGroup ? TGLocalized(@"Notification.CreatedGroup") : TGLocalized(@"Notification.CreatedChannel");
            
            break;
        }
        case TGMessageActionGroupMigratedTo:
        {
            actionText = TGLocalized(@"Notification.GroupMigratedToChannel");
            break;
        }
        case TGMessageActionGroupActivated:
        {
            actionText = TGLocalized(@"Notification.GroupDeactivated");
            break;
        }
        case TGMessageActionGroupDeactivated:
        {
            actionText = TGLocalized(@"Notification.GroupActivated");
            break;
        }
        case TGMessageActionChannelMigratedFrom:
        {
            actionText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChannelMigratedFrom"), actionMedia.actionData[@"title"]];
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
            NSString *formatString = nil;
            if (_context.conversation.isChannelGroup) {
                formatString = TGLocalized(@"Notification.GroupInviter");
            } else {
                formatString = TGLocalized(@"Notification.ChannelInviter");
            }
            if (authorUid == [actionMedia.actionData[@"uid"] intValue] || [actionMedia.actionData[@"uid"] intValue] == TGTelegraphInstance.clientUserId) {
                if (_context.conversation.isChannelGroup) {
                    actionText = TGLocalized(@"Notification.GroupInviterSelf");
                } else {
                    actionText = TGLocalized(@"Notification.ChannelInviterSelf");
                }
            } else {
                int32_t inviterUid = [actionMedia.actionData[@"uid"] intValue];
                NSString *inviterName = nil;
                for (TGUser *user in additionalUsers) {
                    if (user.uid == inviterUid) {
                        inviterName = user.displayName;
                        break;
                    }
                }
                actionText = [[NSString alloc] initWithFormat:formatString, inviterName];
                
                NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                if (formatNameRange.location != NSNotFound && inviterUid != 0)
                {
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange range = NSMakeRange(formatNameRange.location, inviterName.length);
                    additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                    
                    textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", inviterUid]]], nil];
                }
            }
            
            break;
        }
        case TGMessageActionCreateBroadcastList:
        {
            NSString *formatString = TGLocalized(@"Notification.CreatedBroadcastList");
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
            
            if (_context.isAdminLog) {
                if (_context.adminLogIsGroup) {
                    formatString = imageUrl != nil ? TGLocalized(@"Group.MessagePhotoUpdated") : TGLocalized(@"Group.MessagePhotoRemoved");
                } else {
                    formatString = imageUrl != nil ? TGLocalized(@"Channel.MessagePhotoUpdated") : TGLocalized(@"Channel.MessagePhotoRemoved");
                }
            } else if (TGPeerIdIsChannel(message.cid)) {
                if (_context.conversation.isChannelGroup) {
                    formatString = imageUrl != nil ? TGLocalized(@"Group.MessagePhotoUpdated") : TGLocalized(@"Group.MessagePhotoRemoved");
                } else {
                    formatString = imageUrl != nil ? TGLocalized(@"Channel.MessagePhotoUpdated") : TGLocalized(@"Channel.MessagePhotoRemoved");
                }
            } else {
                formatString = imageUrl != nil ? TGLocalized(@"Notification.ChangedGroupPhoto") : TGLocalized(@"Notification.RemovedGroupPhoto");
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
            NSString *formatString = TGLocalized(@"Notification.Joined");
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
            
            NSString *formatString = TGLocalized(@"Notification.ChangedUserPhoto");
            
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
                    actionText = TGLocalized(@"Notification.MessageLifetimeRemovedOutgoing");
                else
                {
                    NSString *authorName = authorTitle;
                    NSString *formatString = TGLocalized(@"Notification.MessageLifetimeRemoved");
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
                    actionText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.MessageLifetimeChangedOutgoing"), lifetimeString];
                else
                {
                    NSString *authorName = authorTitle;
                    NSString *formatString = TGLocalized(@"Notification.MessageLifetimeChanged");
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
            if (message.outgoing) {
                actionText = TGLocalized(@"Notification.SecretChatMessageScreenshotSelf");
            }
            else
            {
                NSString *authorName = authorShortTitle;
                
                NSString *formatString = TGLocalized(@"Notification.SecretChatMessageScreenshot");
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
        case TGMessageActionPinnedMessage:
        {
            TGMessage *replyMessage = nil;
            for (id attachment in message.mediaAttachments) {
                if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
                    replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                    break;
                }
            }
            
            _navigateToMessageId = replyMessage.mid;
            
            NSString *formatString = replyMessage != nil ? TGLocalized(@"Notification.PinnedTextMessage") : TGLocalized(@"Notification.PinnedDeletedMessage");
            for (id attachment in replyMessage.mediaAttachments) {
                if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
                    formatString = TGLocalized(@"Notification.PinnedPhotoMessage");
                } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
                    if (((TGVideoMediaAttachment *)attachment).roundMessage)
                        formatString = TGLocalized(@"Notification.PinnedRoundMessage");
                    else
                        formatString = TGLocalized(@"Notification.PinnedVideoMessage");
                } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                    TGDocumentMediaAttachment *document = attachment;
                    if ([document isAnimated]) {
                        formatString = TGLocalized(@"Notification.PinnedAnimationMessage");
                    } else {
                        bool isSticker = false;
                        bool isAudio = false;
                        bool isVoice = false;
                        
                        for (id attribute in document.attributes) {
                            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                                isAudio = true;
                                isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
                            } else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                                isSticker = true;
                            }
                        }
                        
                        if (isSticker) {
                            formatString = TGLocalized(@"Notification.PinnedStickerMessage");
                        } else if (isVoice) {
                            formatString = TGLocalized(@"Notification.PinnedAudioMessage");
                        } else {
                            formatString = TGLocalized(@"Notification.PinnedDocumentMessage");
                        }
                    }
                } else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]]) {
                    formatString = TGLocalized(@"Notification.PinnedLocationMessage");
                } else if ([attachment isKindOfClass:[TGContactMediaAttachment class]]) {
                    formatString = TGLocalized(@"Notification.PinnedContactMessage");
                } else if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                    formatString = TGLocalized(@"PINNED_GAME");
                } else if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
                    formatString = TGLocalized(@"PINNED_INVOICE");
                }
            }
            
            NSString *authorName = authorTitle;
            NSString *text = replyMessage.text;
            if (text.length > 14) {
                text = [[text substringToIndex:14] stringByAppendingString:@"..."];
            }
            actionText = [[NSString alloc] initWithFormat:formatString, authorName, text];
            
            break;
        }
        case TGMessageActionGameScore:
        {
            TGMessage *replyMessage = nil;
            for (id attachment in message.mediaAttachments) {
                if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
                    _navigateToMessageId = ((TGReplyMessageMediaAttachment *)attachment).replyMessageId;
                    replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                    break;
                }
            }
            
            NSString *gameTitle = nil;
            for (id attachment in replyMessage.mediaAttachments) {
                if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                    gameTitle = ((TGGameMediaAttachment *)attachment).title;
                    break;
                }
            }
            
            int scoreCount = (int)[actionMedia.actionData[@"score"] intValue];
            
            NSString *formatStringBase = @"";
            if (gameTitle != nil) {
                if (authorUid == TGTelegraphInstance.clientUserId) {
                    formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSelfExtended_" value:scoreCount];
                } else {
                    formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreExtended_" value:scoreCount];
                }
            } else {
                if (authorUid == TGTelegraphInstance.clientUserId) {
                    formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSelfSimple_" value:scoreCount];
                } else {
                    formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSimple_" value:scoreCount];
                }
            }
            
            NSString *baseString = TGLocalized(formatStringBase);
            baseString = [baseString stringByReplacingOccurrencesOfString:@"%@" withString:@"{score}"];
            
            NSMutableString *formatString = [[NSMutableString alloc] initWithString:baseString];
            
            NSString *authorName = authorTitle;
            
            NSMutableArray *addAttributes = [[NSMutableArray alloc] init];
            NSMutableArray *addTextCheckingResults = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < 3; i++) {
                NSRange nameRange = [formatString rangeOfString:@"{name}"];
                NSRange scoreRange = [formatString rangeOfString:@"{score}"];
                NSRange gameTitleRange = [formatString rangeOfString:@"{game}"];
                
                if (nameRange.location != NSNotFound) {
                    if (scoreRange.location == NSNotFound || scoreRange.location > nameRange.location) {
                        scoreRange.location = NSNotFound;
                    }
                    if (gameTitleRange.location == NSNotFound || gameTitleRange.location > nameRange.location) {
                        gameTitleRange.location = NSNotFound;
                    }
                }
                
                if (scoreRange.location != NSNotFound) {
                    if (nameRange.location == NSNotFound || nameRange.location > scoreRange.location) {
                        nameRange.location = NSNotFound;
                    }
                    if (gameTitleRange.location == NSNotFound || gameTitleRange.location > scoreRange.location) {
                        gameTitleRange.location = NSNotFound;
                    }
                }
                
                if (gameTitleRange.location != NSNotFound) {
                    if (scoreRange.location == NSNotFound || scoreRange.location > gameTitleRange.location) {
                        scoreRange.location = NSNotFound;
                    }
                    if (nameRange.location == NSNotFound || nameRange.location > gameTitleRange.location) {
                        nameRange.location = NSNotFound;
                    }
                }
                
                if (nameRange.location != NSNotFound) {
                    [formatString replaceCharactersInRange:nameRange withString:authorName];
                    
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange fixedRange = NSMakeRange(nameRange.location, authorName.length);
                    [addAttributes addObject:[[NSValue alloc] initWithBytes:&fixedRange objCType:@encode(NSRange)]];
                    [addAttributes addObject:fontAttributes];
                    
                    [addTextCheckingResults addObject:[NSTextCheckingResult linkCheckingResultWithRange:fixedRange URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]]];
                }
                
                if (scoreRange.location != NSNotFound) {
                    [formatString replaceCharactersInRange:scoreRange withString:[NSString stringWithFormat:@"%d", scoreCount]];
                }
                
                if (gameTitleRange.location != NSNotFound) {
                    [formatString replaceCharactersInRange:gameTitleRange withString:gameTitle ?: @""];
                    
                    NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                    NSRange fixedRange = NSMakeRange(gameTitleRange.location, gameTitle.length);
                    [addAttributes addObject:[[NSValue alloc] initWithBytes:&fixedRange objCType:@encode(NSRange)]];
                    [addAttributes addObject:fontAttributes];
                    
                    //[addTextCheckingResults addObject:[NSTextCheckingResult linkCheckingResultWithRange:fixedRange URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"activate-app://%d", message.mid]]]];
                }
            }
            
            additionalAttributes = addAttributes;
            textCheckingResults = addTextCheckingResults;
            actionText = formatString;
            
            break;
        }
        case TGMessageActionPhoneCall:
        {
            _callForMessageId = message.mid;
            
            bool outgoing = authorUid == TGTelegraphInstance.clientUserId;
            int reason = [actionMedia.actionData[@"reason"] intValue];
            bool missed = reason == TGCallDiscardReasonMissed || reason == TGCallDiscardReasonBusy;
            
            NSString *type = TGLocalized(missed ? (outgoing ? @"Notification.CallCanceled" : @"Notification.CallMissed") : (outgoing ? @"Notification.CallOutgoing" : @"Notification.CallIncoming"));
            
            int callDuration = [message.actionInfo.actionData[@"duration"] intValue];
            NSString *duration = missed || callDuration < 1 ? nil : [TGStringUtils stringForCallDurationSeconds:callDuration];
            NSString *title = duration != nil ? [NSString stringWithFormat:TGLocalized(@"Notification.CallTimeFormat"), type, duration] : type;
            NSString *time = [TGDateUtils stringForShortTime:(int)message.date daytimeVariant:NULL];
            
            NSString *formatString = TGLocalized(@"Notification.CallFormat");
            actionText = [[NSString alloc] initWithFormat:formatString, title, time];
            
            NSRange typeRange = [actionText rangeOfString:type];
            if (typeRange.location != NSNotFound)
            {
                NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&typeRange objCType:@encode(NSRange)], fontAttributes, nil];
            }
            break;
        }
        case TGMessageActionPaymentSent: {
            TGMessage *replyMessage = nil;
            for (id attachment in message.mediaAttachments) {
                if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
                    _navigateToMessageId = ((TGReplyMessageMediaAttachment *)attachment).replyMessageId;
                    replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                    break;
                }
            }
            
            NSString *stringAmount = [[TGCurrencyFormatter shared] formatAmount:[_actionMedia.actionData[@"totalAmount"] longLongValue] currency:_actionMedia.actionData[@"currency"]];
            
            if (replyMessage != nil) {
                NSString *invoiceTitle = nil;
                for (id attachment in replyMessage.mediaAttachments) {
                    if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
                        invoiceTitle = ((TGInvoiceMediaAttachment *)attachment).title;
                        break;
                    }
                }
                
                NSString *formatStringBase = @"Notification.PaymentSent";
                
                NSMutableString *formatString = [[NSMutableString alloc] initWithString:TGLocalized(formatStringBase)];
                
                NSString *authorName = findUserInArray((int32_t)replyMessage.fromUid, additionalUsers).displayName;
                if (authorName == nil) {
                    authorName = @"";
                }
                
                NSMutableArray *addAttributes = [[NSMutableArray alloc] init];
                NSMutableArray *addTextCheckingResults = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < 3; i++) {
                    NSRange nameRange = [formatString rangeOfString:@"{name}"];
                    NSRange amountRange = [formatString rangeOfString:@"{amount}"];
                    NSRange titleRange = [formatString rangeOfString:@"{title}"];
                    
                    if (nameRange.location != NSNotFound) {
                        if (amountRange.location == NSNotFound || amountRange.location > nameRange.location) {
                            amountRange.location = NSNotFound;
                        }
                        if (titleRange.location == NSNotFound || titleRange.location > nameRange.location) {
                            titleRange.location = NSNotFound;
                        }
                    }
                    
                    if (amountRange.location != NSNotFound) {
                        if (nameRange.location == NSNotFound || nameRange.location > amountRange.location) {
                            nameRange.location = NSNotFound;
                        }
                        if (titleRange.location == NSNotFound || titleRange.location > amountRange.location) {
                            titleRange.location = NSNotFound;
                        }
                    }
                    
                    if (titleRange.location != NSNotFound) {
                        if (amountRange.location == NSNotFound || amountRange.location > titleRange.location) {
                            amountRange.location = NSNotFound;
                        }
                        if (nameRange.location == NSNotFound || nameRange.location > titleRange.location) {
                            nameRange.location = NSNotFound;
                        }
                    }
                    
                    if (nameRange.location != NSNotFound) {
                        [formatString replaceCharactersInRange:nameRange withString:authorName];
                        
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange fixedRange = NSMakeRange(nameRange.location, authorName.length);
                        [addAttributes addObject:[[NSValue alloc] initWithBytes:&fixedRange objCType:@encode(NSRange)]];
                        [addAttributes addObject:fontAttributes];
                        
                        [addTextCheckingResults addObject:[NSTextCheckingResult linkCheckingResultWithRange:fixedRange URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]]];
                    }
                    
                    if (amountRange.location != NSNotFound) {
                        [formatString replaceCharactersInRange:amountRange withString:stringAmount];
                        
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange fixedRange = NSMakeRange(amountRange.location, stringAmount.length);
                        [addAttributes addObject:[[NSValue alloc] initWithBytes:&fixedRange objCType:@encode(NSRange)]];
                        [addAttributes addObject:fontAttributes];
                    }
                    
                    if (titleRange.location != NSNotFound) {
                        [formatString replaceCharactersInRange:titleRange withString:invoiceTitle];
                        
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange fixedRange = NSMakeRange(titleRange.location, invoiceTitle.length);
                        [addAttributes addObject:[[NSValue alloc] initWithBytes:&fixedRange objCType:@encode(NSRange)]];
                        [addAttributes addObject:fontAttributes];
                    }
                }
                
                additionalAttributes = addAttributes;
                textCheckingResults = addTextCheckingResults;
                actionText = formatString;
            } else {
                actionText = [[NSString alloc] initWithFormat:TGLocalized(@"Message.PaymentSent"), stringAmount];
            }
            
            break;
        }
        case TGMessageActionCustom: {
            TGMediaAttachment *expiredMedia = actionMedia.actionData[@"expiredMedia"];
            id<TGChannelAdminLogEntryContent> content = actionMedia.actionData[@"adminLogEntryContent"];
            
            if (expiredMedia != nil) {
                if ([expiredMedia isKindOfClass:[TGImageMediaAttachment class]]) {
                    actionText = TGLocalized(@"Message.ImageExpired");
                } else if ([expiredMedia isKindOfClass:[TGDocumentMediaAttachment class]]) {
                    actionText = TGLocalized(@"Message.VideoExpired");
                } else if ([expiredMedia isKindOfClass:[TGVideoMediaAttachment class]]) {
                    actionText = TGLocalized(@"Message.VideoExpired");
                }
            } else if (content != nil) {
                if ([content isKindOfClass:[TGChannelAdminLogEntryToggleBan class]]) {
                    TGChannelAdminLogEntryToggleBan *value = (TGChannelAdminLogEntryToggleBan *)content;
                    
                    TGUser *user = findUserInArray([actionMedia.actionData[@"uid"] intValue], additionalUsers);
                    
                    NSMutableString *updates = [[NSMutableString alloc] init];
                    if (value.previousRights.banReadMessages != value.rights.banReadMessages) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.banReadMessages) {
                            [updates appendString:@"+"];
                        } else {
                            [updates appendString:@"-"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.BanReadMessages")];
                    }
                    if (value.previousRights.banSendMessages != value.rights.banSendMessages) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.banSendMessages) {
                            [updates appendString:@"+"];
                        } else {
                            [updates appendString:@"-"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.BanSendMessages")];
                    }
                    if (value.previousRights.banSendMedia != value.rights.banSendMedia) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.banSendMedia) {
                            [updates appendString:@"+"];
                        } else {
                            [updates appendString:@"-"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.BanSendMedia")];
                    }
                    if (value.previousRights.banSendStickers != value.rights.banSendStickers) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.banSendStickers) {
                            [updates appendString:@"+"];
                        } else {
                            [updates appendString:@"-"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.BanSendStickers")];
                    }
                    if (value.previousRights.banEmbedLinks != value.rights.banEmbedLinks) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.banEmbedLinks) {
                            [updates appendString:@"+"];
                        } else {
                            [updates appendString:@"-"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.BanEmbedLinks")];
                    }
                    
                    NSString *userName = user.displayName;
                    NSString *formatString = TGLocalized(@"Channel.AdminLog.MessageRestricted");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorTitle, userName, updates];
                    
                    NSRange formatNameRangeFirst = [formatString rangeOfString:@"%@"];
                    NSRange formatNameRangeSecond = formatNameRangeFirst.location != NSNotFound ? [formatString rangeOfString:@"%@" options:0 range:NSMakeRange(formatNameRangeFirst.location + formatNameRangeFirst.length, formatString.length - (formatNameRangeFirst.location + formatNameRangeFirst.length))] : NSMakeRange(NSNotFound, 0);
                    
                    if (formatNameRangeFirst.location != NSNotFound && formatNameRangeSecond.location != NSNotFound)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange rangeFirst = NSMakeRange(formatNameRangeFirst.location, authorTitle.length);
                        NSRange rangeSecond = NSMakeRange(rangeFirst.length - formatNameRangeFirst.length + formatNameRangeSecond.location, userName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&rangeFirst objCType:@encode(NSRange)], fontAttributes, [[NSValue alloc] initWithBytes:&rangeSecond objCType:@encode(NSRange)], fontAttributes, nil];
                        
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:rangeFirst URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], [NSTextCheckingResult linkCheckingResultWithRange:rangeSecond URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", user.uid]]], nil];
                    }
                } else if ([content isKindOfClass:[TGChannelAdminLogEntryToggleAdmin class]]) {
                    TGChannelAdminLogEntryToggleAdmin *value = (TGChannelAdminLogEntryToggleAdmin *)content;
                    
                    TGUser *user = findUserInArray([actionMedia.actionData[@"uid"] intValue], additionalUsers);
                    
                    NSMutableString *updates = [[NSMutableString alloc] init];
                    if (value.previousRights.canChangeInfo != value.rights.canChangeInfo) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.canChangeInfo) {
                            [updates appendString:@"-"];
                        } else {
                            [updates appendString:@"+"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.CanChangeInfo")];
                    }
                    if (value.previousRights.canPostMessages != value.rights.canPostMessages) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.canPostMessages) {
                            [updates appendString:@"-"];
                        } else {
                            [updates appendString:@"+"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.CanSendMessages")];
                    }
                    if (value.previousRights.canDeleteMessages != value.rights.canDeleteMessages) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.canDeleteMessages) {
                            [updates appendString:@"-"];
                        } else {
                            [updates appendString:@"+"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.CanDeleteMessages")];
                    }
                    if (value.previousRights.canBanUsers != value.rights.canBanUsers) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.canBanUsers) {
                            [updates appendString:@"-"];
                        } else {
                            [updates appendString:@"+"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.CanBanUsers")];
                    }
                    if (value.previousRights.canInviteUsers != value.rights.canInviteUsers) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.canInviteUsers) {
                            [updates appendString:@"-"];
                        } else {
                            [updates appendString:@"+"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.CanInviteUsers")];
                    }
                    if (value.previousRights.canChangeInviteLink != value.rights.canChangeInviteLink) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.canChangeInviteLink) {
                            [updates appendString:@"-"];
                        } else {
                            [updates appendString:@"+"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.CanChangeInviteLink")];
                    }
                    if (value.previousRights.canPinMessages != value.rights.canPinMessages) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.canPinMessages) {
                            [updates appendString:@"-"];
                        } else {
                            [updates appendString:@"+"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.CanPinMessages")];
                    }
                    if (value.previousRights.canAddAdmins != value.rights.canAddAdmins) {
                        if (updates.length != 0) {
                            [updates appendString:@", "];
                        }
                        if (value.previousRights.canAddAdmins) {
                            [updates appendString:@"-"];
                        } else {
                            [updates appendString:@"+"];
                        }
                        [updates appendString:TGLocalized(@"Channel.AdminLog.CanAddAdmins")];
                    }
                    
                    NSString *userName = user.displayName;
                    NSString *formatString = TGLocalized(@"Channel.AdminLog.MessageAdmin");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorTitle, userName, updates];
                    
                    NSRange formatNameRangeFirst = [formatString rangeOfString:@"%@"];
                    NSRange formatNameRangeSecond = formatNameRangeFirst.location != NSNotFound ? [formatString rangeOfString:@"%@" options:0 range:NSMakeRange(formatNameRangeFirst.location + formatNameRangeFirst.length, formatString.length - (formatNameRangeFirst.location + formatNameRangeFirst.length))] : NSMakeRange(NSNotFound, 0);
                    
                    if (formatNameRangeFirst.location != NSNotFound && formatNameRangeSecond.location != NSNotFound)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange rangeFirst = NSMakeRange(formatNameRangeFirst.location, authorTitle.length);
                        NSRange rangeSecond = NSMakeRange(rangeFirst.length - formatNameRangeFirst.length + formatNameRangeSecond.location, userName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&rangeFirst objCType:@encode(NSRange)], fontAttributes, [[NSValue alloc] initWithBytes:&rangeSecond objCType:@encode(NSRange)], fontAttributes, nil];
                        
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:rangeFirst URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], [NSTextCheckingResult linkCheckingResultWithRange:rangeSecond URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", user.uid]]], nil];
                    }
                } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangeInvites class]]) {
                    TGChannelAdminLogEntryChangeInvites *value = (TGChannelAdminLogEntryChangeInvites *)content;
                    
                    NSString *authorName = authorTitle;
                    NSString *formatString = nil;
                    NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                    if (value.value) {
                        formatString = TGLocalized(@"Channel.AdminLog.MessageToggleInvitesOn");
                        formatNameRange = [formatString rangeOfString:@"%@"];
                    } else {
                        formatString = TGLocalized(@"Channel.AdminLog.MessageToggleInvitesOff");
                        formatNameRange = [formatString rangeOfString:@"%@"];
                    }
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    if (formatNameRange.location != NSNotFound && authorUid != 0)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangeSignatures class]]) {
                    TGChannelAdminLogEntryChangeSignatures *value = (TGChannelAdminLogEntryChangeSignatures *)content;
                    
                    NSString *authorName = authorTitle;
                    NSString *formatString = nil;
                    NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                    if (value.value) {
                        formatString = TGLocalized(@"Channel.AdminLog.MessageToggleSignaturesOn");
                        formatNameRange = [formatString rangeOfString:@"%@"];
                    } else {
                        formatString = TGLocalized(@"Channel.AdminLog.MessageToggleSignaturesOff");
                        formatNameRange = [formatString rangeOfString:@"%@"];
                    }
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    if (formatNameRange.location != NSNotFound && authorUid != 0)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangeUsername class]]) {
                    NSString *authorName = authorTitle;
                    NSString *formatString = nil;
                    NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                    if (((TGChannelAdminLogEntryChangeUsername *)content).username.length != 0) {
                        if (_context.conversation.isChannelGroup) {
                            formatString = TGLocalized(@"Channel.AdminLog.MessageChangedGroupUsername");
                            formatNameRange = [formatString rangeOfString:@"%@"];
                        } else {
                            formatString = TGLocalized(@"Channel.AdminLog.MessageChangedChannelUsername");
                            formatNameRange = [formatString rangeOfString:@"%@"];
                        }
                    } else {
                        if (_context.conversation.isChannelGroup) {
                            formatString = TGLocalized(@"Channel.AdminLog.MessageRemovedGroupUsername");
                            formatNameRange = [formatString rangeOfString:@"%@"];
                        } else {
                            formatString = TGLocalized(@"Channel.AdminLog.MessageRemovedChannelUsername");
                            formatNameRange = [formatString rangeOfString:@"%@"];
                        }
                    }
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    if (formatNameRange.location != NSNotFound && authorUid != 0)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangeAbout class]]) {
                    NSString *authorName = authorTitle;
                    NSString *formatString = nil;
                    NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                    if (!_context.conversation.isChannelGroup) {
                        formatString = TGLocalized(@"Channel.AdminLog.MessageChangedGroupAbout");
                        formatNameRange = [formatString rangeOfString:@"%@"];
                    } else {
                        formatString = TGLocalized(@"Channel.AdminLog.MessageChangedChannelAbout");
                        formatNameRange = [formatString rangeOfString:@"%@"];
                    }
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    if (formatNameRange.location != NSNotFound && authorUid != 0)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                } else if ([content isKindOfClass:[TGChannelAdminLogEntryEditMessage class]]) {
                    TGChannelAdminLogEntryEditMessage *value = (TGChannelAdminLogEntryEditMessage *)content;
                    NSString *authorName = authorTitle;
                    NSString *formatString = nil;
                    NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                    formatString = TGLocalized(@"Channel.AdminLog.MessageEdited");
                    bool isMedia = false;
                    for (id media in value.message.mediaAttachments) {
                        if ([media isKindOfClass:[TGImageMediaAttachment class]]) {
                            isMedia = true;
                        } else if ([media isKindOfClass:[TGVideoMediaAttachment class]]) {
                            isMedia = true;
                        } else if ([media isKindOfClass:[TGDocumentMediaAttachment class]]) {
                            isMedia = true;
                        } else if ([media isKindOfClass:[TGAudioMediaAttachment class]]) {
                            isMedia = true;
                        } else if ([media isKindOfClass:[TGLocationMediaAttachment class]]) {
                            isMedia = true;
                        } else if ([media isKindOfClass:[TGContactMediaAttachment class]]) {
                            isMedia = true;
                        }
                    }
                    if (isMedia) {
                        formatString = TGLocalized(@"Channel.AdminLog.CaptionEdited");
                    }
                    formatNameRange = [formatString rangeOfString:@"%@"];
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    if (formatNameRange.location != NSNotFound && authorUid != 0)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                } else if ([content isKindOfClass:[TGChannelAdminLogEntryDeleteMessage class]]) {
                    NSString *authorName = authorTitle;
                    NSString *formatString = nil;
                    NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                    formatString = TGLocalized(@"Channel.AdminLog.MessageDeleted");
                    formatNameRange = [formatString rangeOfString:@"%@"];
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    if (formatNameRange.location != NSNotFound && authorUid != 0)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangePinnedMessage class]]) {
                    NSString *authorName = authorTitle;
                    NSString *formatString = nil;
                    NSRange formatNameRange = NSMakeRange(NSNotFound, 0);
                    TGChannelAdminLogEntryDeleteMessage *concrete = (TGChannelAdminLogEntryDeleteMessage *)content;
                    if (concrete.message != nil) {
                        formatString = TGLocalized(@"Channel.AdminLog.MessagePinned");
                    } else {
                        formatString = TGLocalized(@"Channel.AdminLog.MessageUnpinned");
                    }
                    formatNameRange = [formatString rangeOfString:@"%@"];
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                    
                    if (formatNameRange.location != NSNotFound && authorUid != 0)
                    {
                        NSArray *fontAttributes = [[NSArray alloc] initWithObjects:(__bridge id)[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleBoldFont], (NSString *)kCTFontAttributeName, nil];
                        NSRange range = NSMakeRange(formatNameRange.location, authorName.length);
                        additionalAttributes = [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
                        textCheckingResults = [[NSArray alloc] initWithObjects:[NSTextCheckingResult linkCheckingResultWithRange:range URL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"tg-user://%d", authorUid]]], nil];
                    }
                }
            }
            break;
        }
        default:
            break;
    }
    
    if (!TGStringCompare(_textModel.text, actionText)) {
        _textModel.text = actionText;
        _textModel.additionalAttributes = additionalAttributes;
        _textModel.textCheckingResults = textCheckingResults;
        
        return true;
    }
    
    return false;
}

- (instancetype)initWithMessage:(TGMessage *)message actionMedia:(TGActionMediaAttachment *)actionMedia authorPeer:(id)authorPeer additionalUsers:(NSArray *)additionalUsers context:(TGModernViewContext *)context
{
    self = [super initWithAuthorPeer:nil context:context];
    if (self != nil)
    {
        _mid = message.mid;
        _authorPeer = authorPeer;
        _additionalUsers = additionalUsers;
        _actionMedia = actionMedia;
        _message = message;
        
        _backgroundModel = [[TGModernImageViewModel alloc] initWithImage:[[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackground]];
        _backgroundModel.skipDrawInContext = true;
        [self addSubmodel:_backgroundModel];
        
        _contentModel = [[TGModernFlatteningViewModel alloc] initWithContext:_context];
        _contentModel.viewUserInteractionDisabled = true;
        [self addSubmodel:_contentModel];
        
        _textModel = [[TGModernTextViewModel alloc] initWithText:@"" font:[[TGTelegraphConversationMessageAssetsSource instance] messageActionTitleFont]];
        _textModel.textColor = [UIColor whiteColor];
        _textModel.layoutFlags = TGReusableLabelLayoutMultiline;
        _textModel.alignment = NSTextAlignmentCenter;
        
        [self setupText];
        
        [_contentModel addSubmodel:_textModel];
    }
    return self;
}

- (void)updateMessage:(TGMessage *)message viewStorage:(TGModernViewStorage *)viewStorage sizeUpdated:(bool *)sizeUpdated
{
    _mid = message.mid;
    _message = message;
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGActionMediaAttachment class]]) {
            _actionMedia = attachment;
            break;
        }
    }
    
    if ([self setupText]) {
        if (sizeUpdated) {
            *sizeUpdated = true;
        }
    }
    
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
    
    if (_callForMessageId != 0)
    {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [backgroundView addGestureRecognizer:_tapRecognizer];
    }
    
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
    
    if (_callForMessageId != 0)
    {
        [backgroundView removeGestureRecognizer:_tapRecognizer];
        _tapRecognizer = nil;
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
            else if (_navigateToMessageId != 0) {
                [_context.companionHandle requestAction:@"navigateToMessage" options:@{@"mid": @(_navigateToMessageId), @"sourceMid": @(_mid)}];
            }
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

- (void)tapGesture:(UITapGestureRecognizer *)__unused recognizer
{
    if (_callForMessageId != 0) {
        [_context.companionHandle requestAction:@"callRequested" options:@{@"mid": @(_callForMessageId)}];
    }
}

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)__unused point
{
    if (recognizer == _boundImageTapRecognizer)
        return 3;
    else if ([_textModel linkAtPoint:point regionData:nil] != nil || _navigateToMessageId != 0)
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

- (bool)isPreviewableAtPoint:(CGPoint)point
{
    return CGRectContainsPoint(_imageModel.frame, point);
}

@end
