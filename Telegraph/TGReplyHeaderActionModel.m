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
            messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RenamedChat"), [self titleForPeer:author shortName:false]];
            break;
        }
        case TGMessageActionChatEditPhoto:
        {
            if ([(TGImageMediaAttachment *)[actionMedia.actionData objectForKey:@"photo"] imageInfo] == nil)
                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.RemovedGroupPhoto"), [self titleForPeer:author shortName:false]];
            else
                messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.ChangedGroupPhoto"), [self titleForPeer:author shortName:false]];
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
            NSNumber *nUid = [actionMedia.actionData objectForKey:@"uid"];
            if (nUid != nil)
            {
                TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                if ([author isKindOfClass:[TGUser class]] && ((TGUser *)author).uid == subjectUser.uid)
                    messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedChat"), [self titleForPeer:author shortName:false]];
                else
                    messageText = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.Invited"), [self titleForPeer:author shortName:false], subjectUser.displayName];
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
            messageText = TGLocalized(@"Notification.CreatedChannel");
            break;
        }
        case TGMessageActionChannelCommentsStatusChanged:
        {
            messageText = [actionMedia.actionData[@"enabled"] boolValue] ? TGLocalized(@"Channel.NotificationCommentsEnabled") : TGLocalized(@"Channel.NotificationCommentsDisabled");;
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
