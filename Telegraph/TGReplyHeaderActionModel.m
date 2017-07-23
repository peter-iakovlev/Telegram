#import "TGReplyHeaderActionModel.h"

#import "TGUser.h"
#import "TGActionMediaAttachment.h"
#import "TGImageMediaAttachment.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"
#import "TGStringUtils.h"
#import "TGCurrencyFormatter.h"

@implementation TGReplyHeaderActionModel

+ (NSString *)titleForPeer:(id)peer shortName:(bool)shortName {
    if ([peer isKindOfClass:[TGUser class]]) {
        if (shortName) {
            return ((TGUser *)peer).displayFirstName;
        } else {
            return ((TGUser *)peer).displayName;
        }
    } else if ([peer isKindOfClass:[TGConversation class]]) {
        return ((TGConversation *)peer).chatTitle;
    }
    return @"";
}

+ (NSString *)messageTextForActionMedia:(TGActionMediaAttachment *)actionMedia otherAttachments:(NSArray *)__unused otherAttachments author:(id)author
{
    NSString *messageText = @"";
    
    switch (actionMedia.actionType)
    {
        case TGMessageActionChatEditTitle:
        {
            if ([author isKindOfClass:[TGConversation class]]) {
                if (((TGConversation *)author).isChannelGroup) {
                    messageText = TGLocalized(@"Notification.RenamedGroup");
                } else {
                    messageText = TGLocalized(@"Notification.RenamedChannel");
                }
            } else {
                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RenamedChat"), [self titleForPeer:author shortName:false]];
            }
            break;
        }
        case TGMessageActionChatEditPhoto:
        {
            if ([(TGImageMediaAttachment *)[actionMedia.actionData objectForKey:@"photo"] imageInfo] == nil) {
                if ([author isKindOfClass:[TGConversation class]]) {
                    if (((TGConversation *)author).isChannelGroup) {
                        messageText = TGLocalized(@"Group.MessagePhotoRemoved");
                    } else {
                        messageText = TGLocalized(@"Channel.MessagePhotoRemoved");
                    }
                } else {
                    messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RemovedGroupPhoto"), [self titleForPeer:author shortName:false]];
                }
            } else {
                if ([author isKindOfClass:[TGConversation class]]) {
                    if (((TGConversation *)author).isChannelGroup) {
                        messageText = TGLocalized(@"Group.MessagePhotoUpdated");
                    } else {
                        messageText = TGLocalized(@"Channel.MessagePhotoUpdated");
                    }
                } else {
                    messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChangedGroupPhoto"), [self titleForPeer:author shortName:false]];
                }
            }
            break;
        }
        case TGMessageActionUserChangedPhoto:
        {
            if ([(TGImageMediaAttachment *)[actionMedia.actionData objectForKey:@"photo"] imageInfo] == nil)
                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RemovedUserPhoto"), [self titleForPeer:author shortName:false]];
            else
                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChangedUserPhoto"), [self titleForPeer:author shortName:false]];
            break;
        }
        case TGMessageActionChatAddMember:
        {
            NSArray *uids = actionMedia.actionData[@"uids"];
            
            if (uids != nil) {
                NSMutableArray *subjectUsers = [[NSMutableArray alloc] init];
                for (NSNumber *nUid in uids) {
                    TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                    if (user != nil) {
                        [subjectUsers addObject:user];
                    }
                }
                
                int32_t authorUid = 0;
                if ([author isKindOfClass:[TGUser class]]) {
                    authorUid = ((TGUser *)author).uid;
                }
                
                if (subjectUsers.count == 1 && authorUid == ((TGUser *)subjectUsers[0]).uid) {
                    messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedChat"), [self titleForPeer:author shortName:false]];
                } else {
                    NSMutableString *subjectNames = [[NSMutableString alloc] init];
                    for (TGUser *user in subjectUsers) {
                        if (subjectNames.length != 0) {
                            [subjectNames appendString:@", "];
                        }
                        [subjectNames appendString:user.displayName];
                    }
                    messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Invited"), [self titleForPeer:author shortName:false], subjectNames];
                }
            } else {
                NSNumber *nUid = [actionMedia.actionData objectForKey:@"uid"];
                if (nUid != nil)
                {
                    TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                    if ([author isKindOfClass:[TGUser class]] && ((TGUser *)author).uid == subjectUser.uid)
                        messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedChat"), [self titleForPeer:author shortName:false]];
                    else
                        messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Invited"), [self titleForPeer:author shortName:false], subjectUser.displayName];
                }
            }
            
            break;
        }
        case TGMessageActionChatDeleteMember:
        {
            NSNumber *nUid = [actionMedia.actionData objectForKey:@"uid"];
            if (nUid != nil)
            {
                TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                if ([author isKindOfClass:[TGUser class]] && ((TGUser *)author).uid == subjectUser.uid)
                    messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.LeftChat"), [self titleForPeer:author shortName:false]];
                else
                    messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Kicked"), [self titleForPeer:author shortName:false], subjectUser.displayName];
            }
            
            break;
        }
        case TGMessageActionCreateChat:
        {
            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.CreatedChat"), [self titleForPeer:author shortName:false]];
            break;
        }
        case TGMessageActionChannelCreated:
        {
            if ([author isKindOfClass:[TGConversation class]] && ((TGConversation *)author).isChannelGroup) {
                messageText = TGLocalized(@"Notification.CreatedGroup");
            } else {
                messageText = TGLocalized(@"Notification.CreatedChannel");
            }

            break;
        }
        case TGMessageActionChannelMigratedFrom:
        {
            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChannelMigratedFrom"), actionMedia.actionData[@"title"]];
            break;
        }
        case TGMessageActionJoinedByLink:
        {
            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedGroupByLink"), [self titleForPeer:author shortName:false]];
            
            break;
        }
        case TGMessageActionPinnedMessage:
        {
            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.PinnedMessage"), [self titleForPeer:author shortName:false]];
            break;
        }
        case TGMessageActionPaymentSent:
        {
            NSString *string = [[TGCurrencyFormatter shared] formatAmount:[actionMedia.actionData[@"totalAmount"] longLongValue] currency:actionMedia.actionData[@"currency"]];
            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Message.PaymentSent"), string];
            break;
        }
        case TGMessageActionGameScore:
        {
            NSString *gameTitle = nil;
            
            int scoreCount = (int)[actionMedia.actionData[@"score"] intValue];
            
            int32_t authorUid = 0;
            if ([author isKindOfClass:[TGUser class]]) {
                authorUid = ((TGUser *)author).uid;
            }
            
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
            baseString = [baseString stringByReplacingOccurrencesOfString:@"%@" withString:@"{game}"];
            
            NSMutableString *formatString = [[NSMutableString alloc] initWithString:baseString];
            
            NSString *authorName = [self titleForPeer:author shortName:false];
            
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
                }
                
                if (scoreRange.location != NSNotFound) {
                    [formatString replaceCharactersInRange:scoreRange withString:[NSString stringWithFormat:@"%d", scoreCount]];
                }
                
                if (gameTitleRange.location != NSNotFound) {
                    [formatString replaceCharactersInRange:gameTitleRange withString:gameTitle ?: @""];
                }
            }
            
            messageText = formatString;
            
            break;
        }
        case TGMessageActionPhoneCall:
        {
            int32_t authorUid = 0;
            if ([author isKindOfClass:[TGUser class]]) {
                authorUid = ((TGUser *)author).uid;
            }

            bool outgoing = authorUid == TGTelegraphInstance.clientUserId;
            int reason = [actionMedia.actionData[@"reason"] intValue];
            bool missed = reason == TGCallDiscardReasonMissed || reason == TGCallDiscardReasonBusy;
            
            NSString *type = TGLocalized(missed ? (outgoing ? @"Notification.CallCanceled" : @"Notification.CallMissed") : (outgoing ? @"Notification.CallOutgoing" : @"Notification.CallIncoming"));
            messageText = type;
            
            break;
        }
        case TGMessageActionEncryptedChatScreenshot:
        case TGMessageActionEncryptedChatMessageScreenshot:
        {
            messageText = TGLocalized(@"Notification.SecretChatScreenshot");
            break;
        }
        default:
            break;
    }
    
    return messageText;
}

- (instancetype)initWithPeer:(id)peer actionMedia:(TGActionMediaAttachment *)actionMedia otherAttachments:(NSArray *)otherAttachments incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:[TGReplyHeaderActionModel messageTextForActionMedia:actionMedia otherAttachments:otherAttachments author:peer] truncateTextInTheMiddle:false textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:0.0f system:system];
    if (self != nil)
    {
    }
    return self;
}

@end
