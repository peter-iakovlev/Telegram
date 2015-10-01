#import "TGChatsRowController.h"
#import "TGDateUtils.h"
#import "TGStringUtils.h"

#import "WKInterfaceGroup+Signals.h"

#import "TGBridgeMediaSignals.h"

#import "TGBridgeChat.h"
#import "TGBridgeUser.h"
#import "TGBridgeUserCache.h"

#import "TGBridgeContext.h"

NSString *const TGChatsRowIdentifier = @"TGChatsRow";

@interface TGChatsRowController ()
{
    NSString *_currentAvatarPhoto;
    NSString *_currentMediaIcon;
}
@end

@implementation TGChatsRowController

- (void)updateWithChat:(TGBridgeChat *)chat context:(TGBridgeContext *)context
{
    bool hasAttachment = false;
    NSString *messageText = nil;
    NSString *messageIcon = nil;
    NSMutableAttributedString *attributedText = nil;
    
    int32_t userId = chat.isGroup ? chat.fromUid : (int32_t)chat.identifier;
    TGBridgeUser *author = [[TGBridgeUserCache instance] userWithId:userId];
    
    for (TGBridgeMediaAttachment *attachment in chat.media)
    {
        if ([attachment isKindOfClass:[TGBridgeImageMediaAttachment class]])
        {
            hasAttachment = true;
            TGBridgeImageMediaAttachment *imageAttachment = (TGBridgeImageMediaAttachment *)attachment;
            if (imageAttachment.caption.length > 0)
                messageText = imageAttachment.caption;
            else
                messageText = TGLocalized(@"Message.Photo");
            
            messageIcon = @"MediaPhoto";
        }
        else if ([attachment isKindOfClass:[TGBridgeVideoMediaAttachment class]])
        {
            hasAttachment = true;
            TGBridgeVideoMediaAttachment *videoAttachment = (TGBridgeVideoMediaAttachment *)attachment;
            if (videoAttachment.caption.length > 0)
                messageText = videoAttachment.caption;
            else
                messageText = TGLocalized(@"Message.Video");
            
            messageIcon = @"MediaVideo";
        }
        else if ([attachment isKindOfClass:[TGBridgeAudioMediaAttachment class]])
        {
            hasAttachment = true;
            messageText = TGLocalized(@"Message.Audio");
            
            messageIcon = @"MediaAudio";
        }
        else if ([attachment isKindOfClass:[TGBridgeDocumentMediaAttachment class]])
        {
            hasAttachment = true;
            TGBridgeDocumentMediaAttachment *documentAttachment = (TGBridgeDocumentMediaAttachment *)attachment;
            
            if (documentAttachment.isSticker)
            {
                if (documentAttachment.stickerAlt.length > 0)
                    messageText = [NSString stringWithFormat:@"%@ %@", documentAttachment.stickerAlt, TGLocalized(@"Message.Sticker")];
                else
                    messageText = TGLocalized(@"Message.Sticker");
            }
            else
            {
                if (documentAttachment.fileName.length > 0)
                    messageText = documentAttachment.fileName;
                else
                    messageText = TGLocalized(@"Message.File");
                
                messageIcon = @"MediaDocument";
            }
        }
        else if ([attachment isKindOfClass:[TGBridgeLocationMediaAttachment class]])
        {
            hasAttachment = true;
            messageText = TGLocalized(@"Message.Location");
            
            messageIcon = @"MediaLocation";
        }
        else if ([attachment isKindOfClass:[TGBridgeContactMediaAttachment class]])
        {
            hasAttachment = true;
            messageText = TGLocalized(@"Message.Contact");
        }
        else if ([attachment isKindOfClass:[TGBridgeActionMediaAttachment class]])
        {
            hasAttachment = true;
            
            TGBridgeActionMediaAttachment *actionAttachment = (TGBridgeActionMediaAttachment *)attachment;
            NSString *actionText = nil;
            NSArray *additionalAttributes = nil;
            
            switch (actionAttachment.actionType)
            {
                case TGBridgeMessageActionChatEditTitle:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    NSString *formatString = TGLocalized(@"Notification.RenamedChat");
                    
                    actionText = [NSString stringWithFormat:formatString, authorName];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        additionalAttributes = [TGChatsRowController _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                    }
                }
                    break;
                    
                case TGBridgeMessageActionChatEditPhoto:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    bool changed = actionAttachment.actionData[@"photo"];
                    
                    NSString *formatString = changed ? TGLocalized(@"Notification.ChangedGroupPhoto") : TGLocalized(@"Notification.RemovedGroupPhoto");
                    
                    actionText = [NSString stringWithFormat:formatString, authorName];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        additionalAttributes = [TGChatsRowController _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                    }
                }
                    break;
                    
                case TGBridgeMessageActionUserChangedPhoto:
                {
                    
                }
                    break;
                    
                case TGBridgeMessageActionChatAddMember:
                case TGBridgeMessageActionChatDeleteMember:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    TGBridgeUser *user = [[TGBridgeUserCache instance] userWithId:[actionAttachment.actionData[@"uid"] int32Value]];
                    
                    if (user.identifier == author.identifier)
                    {
                        NSString *formatString = (actionAttachment.actionType == TGBridgeMessageActionChatAddMember) ? TGLocalized(@"Notification.JoinedChat") : TGLocalized(@"Notification.LeftChat");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            additionalAttributes = [TGChatsRowController _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                        }
                    }
                    else
                    {
                        NSString *userName = [TGStringUtils initialsForFirstName:user.firstName lastName:user.lastName single:false];
                        NSString *formatString = (actionAttachment.actionType == TGBridgeMessageActionChatAddMember) ? TGLocalized(@"Notification.Invited") : TGLocalized(@"Notification.Kicked");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName, userName];
                        
                        NSRange formatNameRangeFirst = [formatString rangeOfString:@"%@"];
                        NSRange formatNameRangeSecond = formatNameRangeFirst.location != NSNotFound ? [formatString rangeOfString:@"%@" options:0 range:NSMakeRange(formatNameRangeFirst.location + formatNameRangeFirst.length, formatString.length - (formatNameRangeFirst.location + formatNameRangeFirst.length))] : NSMakeRange(NSNotFound, 0);
                        
                        if (formatNameRangeFirst.location != NSNotFound && formatNameRangeSecond.location != NSNotFound)
                        {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            
                            NSRange rangeFirst = NSMakeRange(formatNameRangeFirst.location, authorName.length);
                            [array addObjectsFromArray:[TGChatsRowController _mediumFontAttributeForRange:rangeFirst]];
                            [array addObjectsFromArray:[TGChatsRowController _mediumFontAttributeForRange:NSMakeRange(rangeFirst.length - formatNameRangeFirst.length + formatNameRangeSecond.location, userName.length)]];
                            
                            additionalAttributes = array;
                        }
                    }
                }
                    break;
                    
                case TGBridgeMessageActionJoinedByLink:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    NSString *formatString = TGLocalizedStatic(@"Notification.JoinedGroupByLink");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionAttachment.actionData[@"title"]];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        additionalAttributes = [TGChatsRowController _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                    }
                }
                    break;
                    
                case TGBridgeMessageActionCreateChat:
                {
                    NSString *authorName = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
                    NSString *formatString = TGLocalizedStatic(@"Notification.CreatedChatWithTitle");
                    actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionAttachment.actionData[@"title"]];
                    
                    NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                    if (formatNameRange.location != NSNotFound)
                    {
                        additionalAttributes = [TGChatsRowController _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                    }
                }
                    break;
                    
                case TGBridgeMessageActionContactRegistered:
                {
                    messageText = TGLocalized(@"Notification.Joined");
                }
                    break;
                    
                default:
                    break;
            }
            
            if (actionText != nil)
            {
                attributedText = [[NSMutableAttributedString alloc] initWithString:actionText attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0f weight:UIFontWeightRegular], NSForegroundColorAttributeName: [UIColor hexColor:0x8f8f8f] }];
                
                if (additionalAttributes != nil)
                {
                    NSUInteger count = additionalAttributes.count;
                    for (NSUInteger i = 0; i < count; i += 2)
                    {
                        NSRange range = NSMakeRange(0, 0);
                        [(NSValue *)[additionalAttributes objectAtIndex:i] getValue:&range];
                        NSDictionary *attributes = [additionalAttributes objectAtIndex:i + 1];
                        
                        if (range.location + range.length <= attributedText.length)
                            [attributedText addAttributes:attributes range:range];
                    }
                }
            }
        }
        else if ([attachment isKindOfClass:[TGBridgeUnsupportedMediaAttachment class]])
        {
            hasAttachment = true;
            messageText = TGLocalized(@"Message.Unsupported");
        }
    }
    
    if (!hasAttachment)
        messageText = chat.text;
    
    if (messageText == nil)
        messageText = @"";
    
    if (messageText.length > 20)
        messageText = [messageText substringToIndex:20];
    
    messageText = [messageText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (messageIcon != nil)
    {
        self.mediaIcon.hidden = false;
        if (![messageIcon isEqualToString:_currentMediaIcon])
        {
            _currentMediaIcon = messageIcon;
            [self.mediaIcon setImageNamed:messageIcon];
        }
    }
    else
    {
        self.mediaIcon.hidden = true;
    }
    
    if (chat.isGroup)
    {
        self.nameLabel.text = chat.groupTitle;
        
        if (chat.groupPhotoSmall.length > 0)
        {
            self.avatarInitialsLabel.hidden = true;
            self.avatarGroup.backgroundColor = [UIColor hexColor:0x222223];
            if (![_currentAvatarPhoto isEqualToString:chat.groupPhotoSmall])
            {
                _currentAvatarPhoto = chat.groupPhotoSmall;
                [self.avatarGroup setBackgroundImageSignal:[[TGBridgeMediaSignals avatarWithUrl:_currentAvatarPhoto type:TGBridgeMediaAvatarTypeSmall] onError:^(id error)
                {
                    _currentAvatarPhoto = nil;
                }] isVisible:self.isVisible];
            }
        }
        else
        {
            self.avatarInitialsLabel.hidden = false;
            self.avatarGroup.backgroundColor = [TGColor colorForGroupId:chat.identifier];
            self.avatarInitialsLabel.text = [TGStringUtils initialForGroupName:chat.groupTitle];
            
            [self.avatarGroup setBackgroundImageSignal:nil isVisible:self.isVisible];
            _currentAvatarPhoto = nil;
        }
        
        if (attributedText == nil)
        {
            NSString *authorName = (chat.fromUid == context.userId) ? TGLocalized(@"ChatList.You") : [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
            
            if (messageIcon == nil)
            {
                self.initialsLabel.hidden = true;
                attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", authorName] attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightMedium], NSForegroundColorAttributeName: [UIColor whiteColor] }];
                
                [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:messageText]];
            }
            else
            {
                self.initialsLabel.hidden = false;
                self.initialsLabel.text = [NSString stringWithFormat:@"%@:", authorName];
                attributedText = [[NSMutableAttributedString alloc] initWithString:messageText];
            }
        }
        else
        {
            self.initialsLabel.hidden = true;
        }
    }
    else
    {
        self.initialsLabel.hidden = true;
        self.nameLabel.text = author.displayName;
        
        if (author.photoSmall.length > 0)
        {
            self.avatarInitialsLabel.hidden = true;
            self.avatarGroup.backgroundColor = [UIColor hexColor:0x222223];
            if (![_currentAvatarPhoto isEqualToString:author.photoSmall])
            {
                _currentAvatarPhoto = author.photoSmall;
                [self.avatarGroup setBackgroundImageSignal:[[TGBridgeMediaSignals avatarWithUrl:_currentAvatarPhoto type:TGBridgeMediaAvatarTypeSmall] onError:^(id error)
                {
                    _currentAvatarPhoto = nil;
                }] isVisible:self.isVisible];
            }
        }
        else
        {
            self.avatarInitialsLabel.hidden = false;
            [self.avatarGroup setBackgroundImageSignal:nil isVisible:self.isVisible];
            self.avatarGroup.backgroundColor = [TGColor colorForUserId:(int32_t)chat.identifier myUserId:context.userId];
            self.avatarInitialsLabel.text = [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:true];

            _currentAvatarPhoto = nil;
        }
        
        attributedText = [[NSMutableAttributedString alloc] initWithString:messageText];
    }
    
    if (chat.outgoing || chat.deliveryError)
    {
        bool failed = chat.deliveryError;
        self.unreadCountGroup.hidden = !failed;
        
        if (!self.unreadCountGroup.hidden)
        {
            self.unreadCountGroup.width = 15;
            self.unreadCountLabel.text = @"!";
            self.unreadCountGroup.backgroundColor = [UIColor hexColor:0xff4a5c];
        }
        
        self.readGroup.hidden = failed || !(chat.deliveryState == TGBridgeMessageDeliveryStateDelivered && chat.unread);
    }
    else
    {
        self.readGroup.hidden = true;
        
        self.unreadCountGroup.hidden = (chat.unreadCount <= 0);
        self.unreadCountLabel.text = [NSString stringWithFormat:@"%ld", (long)chat.unreadCount];
        self.unreadCountGroup.width = chat.unreadCount < 10 ? 15 : 0;
        self.unreadCountGroup.backgroundColor = [UIColor hexColor:0x2ea4e5];
    }
    
    if (chat.date > 0)
        self.timeLabel.text = [TGDateUtils stringForMessageListDate:chat.date];
    else
        self.timeLabel.text = @"";
    
    self.messageTextLabel.attributedText = attributedText;
}

+ (NSArray *)_mediumFontAttributeForRange:(NSRange)range
{
    NSDictionary *fontAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:16.0f weight:UIFontWeightMedium], NSForegroundColorAttributeName: [UIColor whiteColor] };
    return [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
}

- (void)hideUnreadCountBadge
{
    if (![self.unreadCountLabel.text isEqualToString:@"!"])
        self.unreadCountGroup.hidden = true;
}

- (void)notifyVisiblityChange
{
    [self.avatarGroup updateIfNeeded];
}

+ (NSString *)identifier
{
    return TGChatsRowIdentifier;
}

@end
