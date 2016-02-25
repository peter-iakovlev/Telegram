#import "TGReplyHeaderActionModel.h"

#import "TGUser.h"
#import "TGActionMediaAttachment.h"
#import "TGImageMediaAttachment.h"

#import "TGDatabase.h"

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

+ (NSString *)messageTextForActionMedia:(TGActionMediaAttachment *)actionMedia author:(id)author
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
        default:
            break;
    }
    
    return messageText;
}

- (instancetype)initWithPeer:(id)peer actionMedia:(TGActionMediaAttachment *)actionMedia incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:[TGReplyHeaderActionModel messageTextForActionMedia:actionMedia author:peer] truncateTextInTheMiddle:false textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:0.0f system:system];
    if (self != nil)
    {
    }
    return self;
}

@end
