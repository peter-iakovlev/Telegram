#import "TGPresentationImages.h"
#import "TGPresentationPallete.h"
#import "TGPresentationAssets.h"
#import "TGPresentation.h"

#import "TGWallpaperManager.h"
#import <LegacyComponents/TGWallpaperInfo.h>
#import "TGTelegraphConversationMessageAssetsSource.h"
#import <LegacyComponents/TGCheckButtonView.h>

@interface TGPresentationImages ()
{
    NSCache *_cache;
}

@property (nonatomic, readonly) TGPresentationPallete *pallete;

@end

@implementation TGPresentationImages

#pragma mark - Tabs

- (UIImage *)tabBarContactsIcon
{
    return [self imageWithKey:@"tabContacts" generator:^UIImage *{
        return [TGPresentationAssets tabBarContactsIcon:self.pallete.tabIconColor];
    }];
}

- (UIImage *)tabBarCallsIcon
{
    return [self imageWithKey:@"tabCalls" generator:^UIImage *{
        return [TGPresentationAssets tabBarCallsIcon:self.pallete.tabIconColor];
    }];
}

- (UIImage *)tabBarChatsIcon
{
    return [self imageWithKey:@"tabChats" generator:^UIImage *{
        return [TGPresentationAssets tabBarChatsIcon:self.pallete.tabIconColor downArrow:nil];
    }];
}

- (UIImage *)tabBarChatsUpIcon
{
    return [self imageWithKey:@"tabChatsUp" generator:^UIImage *{
        return [TGPresentationAssets tabBarChatsIcon:self.pallete.tabIconColor downArrow:@false];
    }];
}

- (UIImage *)tabBarChatsDownIcon
{
    return [self imageWithKey:@"tabChatsDown" generator:^UIImage *{
        return [TGPresentationAssets tabBarChatsIcon:self.pallete.tabIconColor downArrow:@true];
    }];
}

- (UIImage *)tabBarSettingsIcon
{
    return [self imageWithKey:@"tabSettings" generator:^UIImage *{
        return [TGPresentationAssets tabBarSettingsIcon:self.pallete.tabIconColor];
    }];
}

- (UIImage *)tabBarBadgeImage
{
    return [self imageWithKey:@"tabBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:18.0f color:self.pallete.tabBadgeColor border:1.0f borderColor:self.pallete.tabBadgeBorderColor];
    }];
}

- (UIImage *)contactsInviteIcon
{
    return [self imageWithKey:@"contactsInvite" generator:^UIImage *{
        return [TGPresentationAssets contactsInviteIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)contactsShareIcon
{
    return [self imageWithKey:@"contactsShare" generator:^UIImage *{
        return [TGPresentationAssets contactsShareIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)contactsNewGroupIcon
{
    return [self imageWithKey:@"contactsGroup" generator:^UIImage *{
        return [TGPresentationAssets contactsNewGroupIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)contactsNewEncryptedIcon
{
    return [self imageWithKey:@"contactsEncrypted" generator:^UIImage *{
        return [TGPresentationAssets contactsNewEncryptedIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)contactsNewChannelIcon
{
    return [self imageWithKey:@"contactsChannel" generator:^UIImage *{
        return [TGPresentationAssets contactsNewChannelIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)contactsUpgradeIcon
{
    return [self imageWithKey:@"contactsUpgrade" generator:^UIImage *{
        return [TGPresentationAssets contactsUpgradeIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)contactsInviteLinkIcon
{
    return [self imageWithKey:@"contactsInviteLink" generator:^UIImage *{
        return [TGPresentationAssets contactsInviteLinkIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)searchClearIcon
{
    return [self imageWithKey:@"searchClear" generator:^UIImage *{
        return [TGPresentationAssets searchClearIcon:self.pallete.searchBarPlaceholderColor color:self.pallete.searchBarClearIconColor];
    }];
}

- (UIImage *)dialogMutedIcon
{
    return [self imageWithKey:@"dialogMuted" generator:^UIImage *{
        return [TGPresentationAssets chatMutedIcon:self.pallete.dialogBadgeMutedColor];
    }];
}

- (UIImage *)dialogVerifiedIcon
{
    return [self imageWithKey:@"dialogVerified" generator:^UIImage *{
        return [TGPresentationAssets chatVerifiedIcon:self.pallete.dialogVerifiedBackgroundColor color:self.pallete.dialogVerifiedIconColor];
    }];
}

- (UIImage *)dialogEncryptedIcon
{
    return [self imageWithKey:@"dialogEncrypted" generator:^UIImage *{
        return [TGPresentationAssets chatEncryptedIcon:self.pallete.dialogEncryptedColor];
    }];
}

- (UIImage *)dialogDeliveredIcon
{
    return [self imageWithKey:@"dialogDelivered" generator:^UIImage *{
        return [TGPresentationAssets chatDeliveredIcon:self.pallete.dialogChecksColor];
    }];
}

- (UIImage *)dialogReadIcon
{
    return [self imageWithKey:@"dialogRead" generator:^UIImage *{
        return [TGPresentationAssets chatReadIcon:self.pallete.dialogChecksColor];
    }];
}

- (UIImage *)dialogPendingIcon
{
    return [self imageWithKey:@"dialogPending" generator:^UIImage *{
        return [TGPresentationAssets chatPendingIcon:self.pallete.dialogDateColor];
    }];
}

- (UIImage *)dialogUnsentIcon
{
    return [self imageWithKey:@"dialogUnsent" generator:^UIImage *{
        return [TGPresentationAssets chatUnsentIcon:self.pallete.dialogUnsentColor];
    }];
}

- (UIImage *)dialogPinnedIcon
{
    return [self imageWithKey:@"dialogPinned" generator:^UIImage *{
        return [TGPresentationAssets chatPinnedIcon:self.pallete.dialogPinnedIconColor];
    }];
}

- (UIImage *)dialogMentionedIcon
{
    return [self imageWithKey:@"dialogMentioned" generator:^UIImage *{
        return [TGPresentationAssets chatMentionedIcon:self.pallete.dialogBadgeColor color:self.pallete.dialogBadgeTextColor];
    }];
}

- (UIImage *)dialogBadgeImage
{
    return [self imageWithKey:@"dialogBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:20.0f color:self.pallete.dialogBadgeColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)dialogMutedBadgeImage
{
    return [self imageWithKey:@"dialogMutedBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:20.0f color:self.pallete.dialogBadgeMutedColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)dialogRecentBadgeImage
{
    return [self imageWithKey:@"dialogRecentBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:22.0f color:self.pallete.dialogBadgeColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)dialogEditingDeleteImage
{
    return [self imageWithKey:@"dialogEditingDelete" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:20.0f color:self.pallete.dialogBadgeColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)dialogEditingReorderImage
{
    return [self imageWithKey:@"dialogEditingReorder" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:20.0f color:self.pallete.dialogBadgeMutedColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)dialogEditDeleteIcon
{
    return [self imageWithKey:@"dialogDelete" generator:^UIImage *{
        return [TGPresentationAssets chatEditDeleteIcon:self.pallete.dialogEditTextColor];
    }];
}

- (UIImage *)dialogEditMuteIcon
{
    return [self imageWithKey:@"dialogMute" generator:^UIImage *{
        return [TGPresentationAssets chatEditMuteIcon:self.pallete.dialogEditTextColor];
    }];
}

- (UIImage *)dialogEditUnmuteIcon
{
    return [self imageWithKey:@"dialogUnmute" generator:^UIImage *{
        return [TGPresentationAssets chatEditUnmuteIcon:self.pallete.dialogEditTextColor];
    }];
}

- (UIImage *)dialogEditPinIcon
{
    return [self imageWithKey:@"dialogPin" generator:^UIImage *{
        return [TGPresentationAssets chatEditPinIcon:self.pallete.dialogEditTextColor];
    }];
}

- (UIImage *)dialogEditUnpinIcon
{
    return [self imageWithKey:@"dialogUnpin" generator:^UIImage *{
        return [TGPresentationAssets chatEditUnpinIcon:self.pallete.dialogEditTextColor];
    }];
}

- (UIImage *)dialogEditGroupIcon
{
    return [self imageWithKey:@"dialogGroup" generator:^UIImage *{
        return [TGPresentationAssets chatEditGroupIcon:self.pallete.dialogEditTextColor];
    }];
}

- (UIImage *)dialogEditUngroupIcon
{
    return [self imageWithKey:@"dialogUngroup" generator:^UIImage *{
        return [TGPresentationAssets chatEditUngroupIcon:self.pallete.dialogEditTextColor];
    }];
}

- (UIImage *)dialogLockBaseIcon
{
    return [self imageWithKey:@"dialogLockBase" generator:^UIImage *{
        return [TGPresentationAssets chatsLockBaseIcon:self.pallete.navigationTitleColor];
    }];
}

- (UIImage *)dialogLockBaseActiveIcon
{
    return [self imageWithKey:@"dialogLockBaseActive" generator:^UIImage *{
        return [TGPresentationAssets chatsLockBaseIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)dialogLockTopIcon
{
    return [self imageWithKey:@"dialogLockTop" generator:^UIImage *{
        return [TGPresentationAssets chatsLockTopIcon:self.pallete.navigationTitleColor active:false];
    }];
}

- (UIImage *)dialogLockTopActiveIcon
{
    return [self imageWithKey:@"dialogLockTopActve" generator:^UIImage *{
        return [TGPresentationAssets chatsLockTopIcon:self.pallete.navigationButtonColor active:true];
    }];
}

- (UIImage *)dialogProxyShieldIcon
{
    return [self imageWithKey:@"proxyShield" generator:^UIImage *{
        return [TGPresentationAssets chatsProxyIcon:self.pallete.navigationButtonColor connected:false onlyShield:true];
    }];
}

- (UIImage *)dialogProxyConnectIcon
{
    return [self imageWithKey:@"proxyConnect" generator:^UIImage *{
        return [TGPresentationAssets chatsProxyIcon:self.pallete.navigationButtonColor connected:false onlyShield:false];
    }];
}

- (UIImage *)dialogProxyConnectedIcon
{
    return [self imageWithKey:@"proxyConnected" generator:^UIImage *{
        return [TGPresentationAssets chatsProxyIcon:self.pallete.navigationButtonColor connected:true onlyShield:false];
    }];
}

- (UIImage *)dialogProxySpinner
{
    return [self imageWithKey:@"proxySpinner" generator:^UIImage *{
        return [TGPresentationAssets chatsProxySpinner:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)callsNewIcon
{
    return [self imageWithKey:@"callsNew" generator:^UIImage *{
        return [TGPresentationAssets callsNewIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)callsInfoIcon
{
    return [self imageWithKey:@"callsInfo" generator:^UIImage *{
        return [TGPresentationAssets callsInfoIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)callsOutgoingIcon
{
    return [self imageWithKey:@"callsOutgoing" generator:^UIImage *{
        return [TGPresentationAssets callsOutgoingIcon:self.pallete.callsOutgoingIconColor];
    }];
}

- (UIImage *)chatNavBadgeImage
{
    return [self imageWithKey:@"chatNavBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:17.0f color:self.pallete.navigationBadgeColor border:1.0f borderColor:self.pallete.navigationBadgeBorderColor];
    }];
}

- (UIImage *)chatTitleMutedIcon
{
    return [self imageWithKey:@"chatTitleMuted" generator:^UIImage *{
        return [TGPresentationAssets chatTitleMutedIcon:self.pallete.dialogBadgeMutedColor];
    }];
}

- (UIImage *)chatTitleEncryptedIcon
{
    return [self imageWithKey:@"chatTitleEncrypted" generator:^UIImage *{
        return [TGPresentationAssets chatTitleEncryptedIcon:self.pallete.navigationTitleColor];
    }];
}

- (UIImage *)chatLiveLocationIcon
{
    return [self imageWithKey:@"chatLiveLocation" generator:^UIImage *{
        return [TGPresentationAssets chatTitleLiveLocationIcon:self.pallete.navigationButtonColor active:false];
    }];
}

- (UIImage *)chatLiveLocationActiveIcon
{
    return [self imageWithKey:@"chatLiveLocationActive" generator:^UIImage *{
        return [TGPresentationAssets chatTitleLiveLocationIcon:self.pallete.navigationButtonColor active:true];
    }];
}

- (UIImage *)chatTitleMuteIcon
{
    return [self imageWithKey:@"chatTitleMute" generator:^UIImage *{
        return [TGPresentationAssets chatTitleMuteIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatTitleUnmuteIcon
{
    return [self imageWithKey:@"chatTitleUnmute" generator:^UIImage *{
        return [TGPresentationAssets chatTitleUnmuteIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatTitleSearchIcon
{
    return [self imageWithKey:@"chatTitleSearch" generator:^UIImage *{
        return [TGPresentationAssets chatTitleSearchIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatTitleReportIcon
{
    return [self imageWithKey:@"chatTitleReport" generator:^UIImage *{
        return [TGPresentationAssets chatTitleReportIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatTitleInfoIcon
{
    return [self imageWithKey:@"chatTitleInfo" generator:^UIImage *{
        return [TGPresentationAssets chatTitleInfoIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatTitleCallIcon
{
    return [self imageWithKey:@"chatTitleCall" generator:^UIImage *{
        return [TGPresentationAssets chatTitleCallIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatTitleGroupIcon
{
    return [self imageWithKey:@"chatTitleGroup" generator:^UIImage *{
        return [TGPresentationAssets chatTitleGroupIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatSearchNextIcon
{
    return [self imageWithKey:@"chatSearchNext" generator:^UIImage *{
        return [TGPresentationAssets chatSearchNextIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatSearchNextDisabledIcon
{
    return [self imageWithKey:@"chatSearchNextDisabled" generator:^UIImage *{
        return [TGPresentationAssets chatSearchNextIcon:self.pallete.navigationDisabledButtonColor];
    }];
}

- (UIImage *)chatSearchPreviousIcon
{
    return [self imageWithKey:@"chatSearchPrev" generator:^UIImage *{
        return [TGPresentationAssets chatSearchPreviousIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatSearchPreviousDisabledIcon
{
    return [self imageWithKey:@"chatSearchPrevDisabled" generator:^UIImage *{
        return [TGPresentationAssets chatSearchPreviousIcon:self.pallete.navigationDisabledButtonColor];
    }];
}

- (UIImage *)chatSearchCalendarIcon
{
    return [self imageWithKey:@"chatSearchCalendar" generator:^UIImage *{
        return [TGPresentationAssets chatSearchCalendarIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatSearchNameIcon
{
    return [self imageWithKey:@"chatSearchName" generator:^UIImage *{
        return [TGPresentationAssets chatSearchNameIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatMentionsImage
{
    return [self imageWithKey:@"chatMentions" generator:^UIImage *{
        return [TGPresentationAssets chatMentionsButton:self.pallete.chatInputButtonColor backgroundColor:self.pallete.barBackgroundColor borderColor:self.pallete.barSeparatorColor];
    }];
}

- (UIImage *)chatDownImage
{
    return [self imageWithKey:@"chatDown" generator:^UIImage *{
        return [TGPresentationAssets chatDownButton:self.pallete.chatInputButtonColor backgroundColor:self.pallete.barBackgroundColor borderColor:self.pallete.barSeparatorColor];
    }];
}

- (UIImage *)chatBadgeImage
{
    return [self imageWithKey:@"chatBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:22.0f color:self.pallete.accentColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)chatBubbleIncomingFullImage
{
    return [self imageWithKey:@"chatBubbleIncomingFull" generator:^UIImage *{
        return [TGPresentationAssets chatBubbleImage:self.pallete.chatIncomingBubbleColor borderColor:self.pallete.chatIncomingBubbleBorderColor outgoing:false hasTail:true];
    }];
}

- (UIImage *)chatBubbleIncomingFullHighlightedImage
{
    return [TGPresentationAssets chatBubbleImage:self.pallete.chatIncomingHighlightedBubbleColor borderColor:self.pallete.chatIncomingHighlightedBubbleBorderColor outgoing:false hasTail:true];
}

- (UIImage *)chatBubbleIncomingPartialImage
{
    return [self imageWithKey:@"chatBubbleIncomingPartial" generator:^UIImage *{
        return [TGPresentationAssets chatBubbleImage:self.pallete.chatIncomingBubbleColor borderColor:self.pallete.chatIncomingBubbleBorderColor outgoing:false hasTail:false];
    }];
}

- (UIImage *)chatBubbleIncomingPartialHighlightedImage
{
    return [TGPresentationAssets chatBubbleImage:self.pallete.chatIncomingHighlightedBubbleColor borderColor:self.pallete.chatIncomingHighlightedBubbleBorderColor outgoing:false hasTail:false];
}

- (UIImage *)chatBubbleOutgoingFullImage
{
    return [self imageWithKey:@"chatBubbleOutgoingFull" generator:^UIImage *{
        return [TGPresentationAssets chatBubbleImage:self.pallete.chatOutgoingBubbleColor borderColor:self.pallete.chatOutgoingBubbleBorderColor outgoing:true hasTail:true];
    }];
}

- (UIImage *)chatBubbleOutgoingFullHighlightedImage
{
    return [TGPresentationAssets chatBubbleImage:self.pallete.chatOutgoingHighlightedBubbleColor borderColor:self.pallete.chatOutgoingHighlightedBubbleBorderColor outgoing:true hasTail:true];
}

- (UIImage *)chatBubbleOutgoingPartialImage
{
    return [self imageWithKey:@"chatBubbleOutgoingPartial" generator:^UIImage *{
        return [TGPresentationAssets chatBubbleImage:self.pallete.chatOutgoingBubbleColor borderColor:self.pallete.chatOutgoingBubbleBorderColor outgoing:true hasTail:false];
    }];
}

- (UIImage *)chatBubbleOutgoingPartialHighlightedImage
{
    return [TGPresentationAssets chatBubbleImage:self.pallete.chatOutgoingHighlightedBubbleColor borderColor:self.pallete.chatOutgoingHighlightedBubbleBorderColor outgoing:true hasTail:false];
}

- (UIImage *)chatPlaceholderBackground
{
    if (self.pallete.chatSystemBackgroundColor == nil) {
        static UIImage *backgroundImage = nil;
        static int backgroundColor = -1;
        
        if (backgroundColor == -1 || backgroundColor != [[TGWallpaperManager instance] currentWallpaperInfo].tintColor)
        {
            backgroundColor = [[TGWallpaperManager instance] currentWallpaperInfo].tintColor;
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0f, 30.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGBA(backgroundColor, 0.35f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 30.0f, 30.0f));
            backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:15 topCapHeight:15];
            UIGraphicsEndImageContext();
        }
        return backgroundImage;
    } else {
        return [self imageWithKey:@"chatPlaceholderBackground" generator:^UIImage *{
            return [TGPresentationAssets chatPlaceholderBackgroundImage:self.pallete.chatSystemBackgroundColor];
        }];
    }
}

- (UIImage *)chatUnreadBackground
{
    return [self imageWithKey:@"chatUnreadBackground" generator:^UIImage *{
        return [TGPresentationAssets chatUnreadBackgroundImage:self.pallete.chatUnreadBackgroundColor borderColor:self.pallete.chatUnreadBorderColor];
    }];
}

- (UIImage *)chatSystemBackground
{
    if (self.pallete.chatSystemBackgroundColor == nil) {
        return [[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackground];
    } else {
        return [self imageWithKey:@"chatSystemBackground" generator:^UIImage *{
            return [TGPresentationAssets chatSystemBackgroundImage:self.pallete.chatSystemBackgroundColor];
        }];
    }
}

- (UIImage *)chatReplyBackground
{
    if (self.pallete.chatSystemBackgroundColor == nil) {
        return [[TGTelegraphConversationMessageAssetsSource instance] systemReplyBackground];
    } else {
        return [self imageWithKey:@"chatReplyBackground" generator:^UIImage *{
            return [TGPresentationAssets chatReplyBackgroundImage:self.pallete.chatSystemBackgroundColor];
        }];
    }
}

- (UIImage *)chatActionShareImage
{
    if (self.pallete.chatActionBackgroundColor == nil) {
        return [[TGTelegraphConversationMessageAssetsSource instance] systemShareButton];
    } else {
        return [self imageWithKey:@"chatActionShare" generator:^UIImage *{
            return [TGPresentationAssets chatActionShareImage:self.pallete.chatActionIconColor backgroundColor:self.pallete.chatActionBackgroundColor borderColor:self.pallete.chatActionBorderColor];
        }];
    }
}

- (UIImage *)chatActionReplyImage
{
    if (self.pallete.chatActionBackgroundColor == nil) {
        return [[TGTelegraphConversationMessageAssetsSource instance] systemSwipeReplyIcon];
    } else {
        return [TGPresentationAssets chatActionReplyImage:self.pallete.chatActionIconColor backgroundColor:self.pallete.chatActionBackgroundColor borderColor:self.pallete.chatActionBorderColor];
    }
}

- (UIImage *)chatActionGoToImage
{
    if (self.pallete.chatActionBackgroundColor == nil) {
        return [[TGTelegraphConversationMessageAssetsSource instance] systemGoToButton];
    } else {
        return [TGPresentationAssets chatActionGoToImage:self.pallete.chatActionIconColor backgroundColor:self.pallete.chatActionBackgroundColor borderColor:self.pallete.chatActionBorderColor];
    }
}

- (UIImage *)chatReplyButtonBackgroundImage
{
    if (self.pallete.chatReplyButtonBackgroundColor == nil) {
        return [[TGTelegraphConversationMessageAssetsSource instance] systemReplyButton];
    } else {
        return [self imageWithKey:@"chatReplyButtonBackground" generator:^UIImage *{
            return [TGPresentationAssets chatReplyButtonImage:self.pallete.chatReplyButtonBackgroundColor borderColor:self.pallete.chatReplyButtonBorderColor];
        }];
    }
}

- (UIImage *)chatReplyButtonHighlightedBackgroundImage
{
    if (self.pallete.chatReplyButtonBackgroundColor == nil) {
        return [[TGTelegraphConversationMessageAssetsSource instance] systemReplyHighlightedButton];
    } else {
        return [self imageWithKey:@"chatReplyButtonHighlightedBackground" generator:^UIImage *{
            return [TGPresentationAssets chatReplyButtonImage:self.pallete.chatReplyButtonHighlightedBackgroundColor borderColor:self.pallete.chatReplyButtonHighlightedBorderColor];
        }];
    }
}

- (UIImage *)chatReplyButtonUrlIcon
{
    return [self imageWithKey:@"chatReplyUrl" generator:^UIImage *{
        return [TGPresentationAssets chatReplyButtonUrlIcon:self.pallete.chatReplyButtonIconColor];
    }];
}

- (UIImage *)chatReplyButtonPhoneIcon
{
    return [self imageWithKey:@"chatReplyPhone" generator:^UIImage *{
        return [TGPresentationAssets chatReplyButtonPhoneIcon:self.pallete.chatReplyButtonIconColor];
    }];
}

- (UIImage *)chatReplyButtonLocationIcon
{
    return [self imageWithKey:@"chatReplyLocation" generator:^UIImage *{
        return [TGPresentationAssets chatReplyButtonLocationIcon:self.pallete.chatReplyButtonIconColor];
    }];
}

- (UIImage *)chatReplyButtonSwitchInlineIcon
{
    return [self imageWithKey:@"chatReplySwitchInline" generator:^UIImage *{
        return [TGPresentationAssets chatReplyButtonSwitchInlineIcon:self.pallete.chatReplyButtonIconColor];
    }];
}

- (UIImage *)chatReplyButtonActionIcon
{
    return [self imageWithKey:@"chatReplyAction" generator:^UIImage *{
        return [TGPresentationAssets chatReplyButtonActionIcon:self.pallete.chatReplyButtonIconColor];
    }];
}

- (UIImage *)chatRoundMessageBackgroundImage
{
    return [self imageWithKey:@"chatRoundMessage" generator:^UIImage *{
        return [TGPresentationAssets chatRoundMessageBackgroundImage:self.pallete.chatRoundMessageBackgroundColor borderColor:self.pallete.chatRoundMessageBorderColor];
    }];
}

- (UIImage *)chatClockFrameIconIncoming
{
    return [self imageWithKey:@"chatClockFrameIncoming" generator:^UIImage *{
        return [TGPresentationAssets chatClockFrameIcon:self.pallete.chatIncomingSubtextColor];
    }];
}

- (UIImage *)chatClockFrameIconOutgoing
{
    return [self imageWithKey:@"chatClockFrameOutgoing" generator:^UIImage *{
        return [TGPresentationAssets chatClockFrameIcon:self.pallete.chatChecksColor];
    }];
}

- (UIImage *)chatClockFrameIconMedia
{
    return [self imageWithKey:@"chatClockFrameMedia" generator:^UIImage *{
        return [TGPresentationAssets chatClockFrameIcon:self.pallete.chatChecksMediaColor];
    }];
}

- (UIImage *)chatClockHourIconIncoming
{
    return [self imageWithKey:@"chatClockHourIncoming" generator:^UIImage *{
        return [TGPresentationAssets chatClockHourIcon:self.pallete.chatIncomingSubtextColor];
    }];
}

- (UIImage *)chatClockHourIconOutgoing
{
    return [self imageWithKey:@"chatClockHourOutgoing" generator:^UIImage *{
        return [TGPresentationAssets chatClockHourIcon:self.pallete.chatChecksColor];
    }];
}

- (UIImage *)chatClockHourIconMedia
{
    return [self imageWithKey:@"chatClockHourMedia" generator:^UIImage *{
        return [TGPresentationAssets chatClockHourIcon:self.pallete.chatChecksMediaColor];
    }];
}

- (UIImage *)chatClockMinuteIconIncoming
{
    return [self imageWithKey:@"chatClockMinuteIncoming" generator:^UIImage *{
        return [TGPresentationAssets chatClockMinuteIcon:self.pallete.chatIncomingSubtextColor];
    }];
}

- (UIImage *)chatClockMinuteIconOutgoing
{
    return [self imageWithKey:@"chatClockMinuteOutgoing" generator:^UIImage *{
        return [TGPresentationAssets chatClockMinuteIcon:self.pallete.chatChecksColor];
    }];
}

- (UIImage *)chatClockMinuteIconMedia
{
    return [self imageWithKey:@"chatClockMinuteMedia" generator:^UIImage *{
        return [TGPresentationAssets chatClockMinuteIcon:self.pallete.chatChecksMediaColor];
    }];
}

- (UIImage *)chatUnsentIcon
{
    return [self imageWithKey:@"chatUnsent" generator:^UIImage *{
        return [TGPresentationAssets chatUnsentMessageIcon:self.pallete.destructiveColor color:self.pallete.accentContrastColor];
    }];
}

- (UIImage *)chatDeliveredIcon
{
    return [self imageWithKey:@"chatDelivered" generator:^UIImage *{
        return [TGPresentationAssets chatDeliveredMessageIcon:self.pallete.chatChecksColor];
    }];
}

- (UIImage *)chatDeliveredIconMedia
{
    return [self imageWithKey:@"chatDeliveredMedia" generator:^UIImage *{
        return [TGPresentationAssets chatDeliveredMessageIcon:self.pallete.chatChecksMediaColor];
    }];
}

- (UIImage *)chatDeliveredIconSticker
{
    return [self imageWithKey:@"chatDeliveredSticker" generator:^UIImage *{
        return [TGPresentationAssets chatDeliveredMessageIcon:self.pallete.chatSystemTextColor];
    }];
}

- (UIImage *)chatReadIcon
{
    return [self imageWithKey:@"chatRead" generator:^UIImage *{
        return [TGPresentationAssets chatReadMessageIcon:self.pallete.chatChecksColor];
    }];
}

- (UIImage *)chatReadIconMedia
{
    return [self imageWithKey:@"chatReadMedia" generator:^UIImage *{
        return [TGPresentationAssets chatReadMessageIcon:self.pallete.chatChecksMediaColor];
    }];
}

- (UIImage *)chatReadIconSticker
{
    return [self imageWithKey:@"chatReadSticker" generator:^UIImage *{
        return [TGPresentationAssets chatReadMessageIcon:self.pallete.chatSystemTextColor];
    }];
}

- (UIImage *)chatIncomingMessageViewsIcon
{
    return [self imageWithKey:@"chatMessageViewsIncoming" generator:^UIImage *{
        return [TGPresentationAssets chatMessageViewsIcon:self.pallete.chatIncomingDateColor];
    }];
}

- (UIImage *)chatOutgoingMessageViewsIcon
{
    return [self imageWithKey:@"chatMessageViewsOutgoing" generator:^UIImage *{
        return [TGPresentationAssets chatMessageViewsIcon:self.pallete.chatOutgoingDateColor];
    }];
}

- (UIImage *)chatMediaMessageViewsIcon
{
    return [self imageWithKey:@"chatMessageViewsMedia" generator:^UIImage *{
        return [TGPresentationAssets chatMessageViewsIcon:self.pallete.chatChecksMediaColor];
    }];
}

- (UIImage *)chatStickerMessageViewsIcon
{
    return [self imageWithKey:@"chatMessageViewsSticker" generator:^UIImage *{
        return [TGPresentationAssets chatMessageViewsIcon:self.pallete.chatSystemTextColor];
    }];
}

- (UIImage *)chatInputFieldImage
{
    return [self imageWithKey:@"chatField" generator:^UIImage *{
        return [TGPresentationAssets inputPanelFieldBackground:self.pallete.chatInputBackgroundColor borderColor:self.pallete.chatInputBorderColor];
    }];
}

- (UIImage *)chatInputAttachIcon
{
    return [self imageWithKey:@"chatAttach" generator:^UIImage *{
        return [TGPresentationAssets inputPanelAttachIcon:self.pallete.chatInputButtonColor accentColor:nil];
    }];
}

- (UIImage *)chatInputAttachEditIcon
{
    return [self imageWithKey:@"chatAttachEdit" generator:^UIImage *{
        return [TGPresentationAssets inputPanelAttachIcon:self.pallete.chatInputButtonColor accentColor:self.pallete.chatInputSendButtonColor];
    }];
}

- (UIImage *)chatInputSendIcon
{
    return [self imageWithKey:@"chatSend" generator:^UIImage *{
        return [TGPresentationAssets inputPanelSendIcon:self.pallete.chatInputSendButtonColor color:self.pallete.chatInputSendButtonIconColor];
    }];
}

- (UIImage *)chatInputConfirmIcon
{
    return [self imageWithKey:@"chatConfirm" generator:^UIImage *{
        return [TGPresentationAssets inputPanelConfirmIcon:self.pallete.chatInputSendButtonColor color:self.pallete.chatInputSendButtonIconColor];
    }];
}

- (UIImage *)chatInputMicrophoneIcon
{
    return [self imageWithKey:@"chatMic" generator:^UIImage *{
        return [TGPresentationAssets inputPanelMicrophoneIcon:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatInputVideoMessageIcon
{
    return [self imageWithKey:@"chatVM" generator:^UIImage *{
        return [TGPresentationAssets inputPanelVideoMessageIcon:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatInputArrowIcon
{
    return [self imageWithKey:@"chatArrow" generator:^UIImage *{
        return [TGPresentationAssets inputPanelArrowIcon:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatInputStickersIcon
{
    return [self imageWithKey:@"chatStickers" generator:^UIImage *{
        return [TGPresentationAssets inputPanelStickersIcon:self.pallete.chatInputFieldButtonColor];
    }];
}

- (UIImage *)chatInputKeyboardIcon
{
    return [self imageWithKey:@"chatKeyboard" generator:^UIImage *{
        return [TGPresentationAssets inputPanelKeyboardIcon:self.pallete.chatInputFieldButtonColor];
    }];
}

- (UIImage *)chatInputCommandsIcon
{
    return [self imageWithKey:@"chatCommands" generator:^UIImage *{
        return [TGPresentationAssets inputPanelCommandsIcon:self.pallete.chatInputFieldButtonColor];
    }];
}

- (UIImage *)chatInputBotKeyboardIcon
{
    return [self imageWithKey:@"chatBotKeyboard" generator:^UIImage *{
        return [TGPresentationAssets inputPanelBotKeyboardIcon:self.pallete.chatInputFieldButtonColor];
    }];
}

- (UIImage *)chatInputBroadcastIcon
{
    return [self imageWithKey:@"chatBroadcast" generator:^UIImage *{
        return [TGPresentationAssets inputPanelBroadcastIcon:self.pallete.chatInputFieldButtonColor active:false];
    }];
}

- (UIImage *)chatInputBroadcastActiveIcon
{
    return [self imageWithKey:@"chatBroadcastActive" generator:^UIImage *{
        return [TGPresentationAssets inputPanelBroadcastIcon:self.pallete.chatInputFieldButtonColor active:true];
    }];
}

- (UIImage *)chatInputTimerIcon
{
    return [self imageWithKey:@"chatTimer" generator:^UIImage *{
        return [TGPresentationAssets inputPanelTimerIcon:self.pallete.chatInputFieldButtonColor];
    }];
}

- (UIImage *)chatInputClearIcon
{
    return [self imageWithKey:@"chatClear" generator:^UIImage *{
        return [TGPresentationAssets inputPanelClearIcon:self.pallete.chatInputFieldButtonColor color:self.pallete.chatInputBackgroundColor];
    }];
}

- (UIImage *)chatBotResultPlaceholderImage
{
    return [self imageWithKey:@"chatBotResultPlaceholder" generator:^UIImage *{
        return [TGPresentationAssets imageWithColor:self.pallete.chatBotResultPlaceholderColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)replyCloseIcon
{
    return [self imageWithKey:@"replyClose" generator:^UIImage *{
        return [TGPresentationAssets replyCloseIcon:self.pallete.secondaryTextColor];
    }];
}

- (UIImage *)pinCloseIcon
{
    return [self imageWithKey:@"pinClose" generator:^UIImage *{
        return [TGPresentationAssets pinCloseIcon:self.pallete.secondaryTextColor];
    }];
}

- (UIImage *)chatStickersGifIcon
{
    return [self imageWithKey:@"stickersGif" generator:^UIImage *{
        return [TGPresentationAssets stickersGifIcon:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatStickersTrendingIcon
{
    return [self imageWithKey:@"stickersTrending" generator:^UIImage *{
        return [TGPresentationAssets stickersTrendingIcon:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatStickersRecentIcon
{
    return [self imageWithKey:@"stickersRecent" generator:^UIImage *{
        return [TGPresentationAssets stickersRecentIcon:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatStickersFavoritesIcon
{
    return [self imageWithKey:@"stickersFavorites" generator:^UIImage *{
        return [TGPresentationAssets stickersFavoritesIcon:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatStickersSettingsIcon
{
    return [self imageWithKey:@"stickersSettings" generator:^UIImage *{
        return [TGPresentationAssets stickersSettingsIcon:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatStickersBadge
{
    return [self imageWithKey:@"stickersBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:16.0f color:self.pallete.chatStickersBadgeColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)chatStickersGroupButton
{
    return [self imageWithKey:@"stickersGroup" generator:^UIImage *{
        return [TGPresentationAssets stickersHollowButton:self.pallete.accentColor radius:6.0f];
    }];
}

- (UIImage *)chatStickersAddButton
{
    return [self imageWithKey:@"stickersAdd" generator:^UIImage *{
        return [TGPresentationAssets stickersHollowButton:self.pallete.accentColor radius:4.0f];
    }];
}

- (UIImage *)chatStickersPlaceholderImage
{
    return [self imageWithKey:@"stickersPlaceholder" generator:^UIImage *{
        return [TGPresentationAssets stickersPlaceholderImage:self.pallete.chatInputButtonColor];
    }];
}

- (UIImage *)chatCommandsKeyboardButtonImage
{
    return [self imageWithKey:@"commandsButton" generator:^UIImage *{
        return [TGPresentationAssets commandsButtonImage:self.pallete.chatInputBotKeyboardButtonColor shadowColor:self.pallete.chatInputBotKeyboardButtonShadowColor];
    }];
}

- (UIImage *)chatCommandsKeyboardHighlightedButtonImage
{
    return [self imageWithKey:@"commandsButtonHighlighted" generator:^UIImage *{
        return [TGPresentationAssets commandsButtonImage:self.pallete.chatInputBotKeyboardButtonHighlightedColor shadowColor:self.pallete.chatInputBotKeyboardButtonShadowColor];
    }];
}

- (UIImage *)chatEditDeleteIcon
{
    return [self imageWithKey:@"chatEditDelete" generator:^UIImage *{
        return [TGPresentationAssets chatDeleteIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatEditDeleteDisabledIcon
{
    return [self imageWithKey:@"chatEditDeleteDisabled" generator:^UIImage *{
        return [TGPresentationAssets chatDeleteIcon:self.pallete.navigationDisabledButtonColor];
    }];
}

- (UIImage *)chatEditShareIcon
{
    return [self imageWithKey:@"chatEditShare" generator:^UIImage *{
        return [TGPresentationAssets chatShareIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatEditShareDisabledIcon
{
    return [self imageWithKey:@"chatEditShareDisabled" generator:^UIImage *{
        return [TGPresentationAssets chatShareIcon:self.pallete.navigationDisabledButtonColor];
    }];
}

- (UIImage *)chatEditForwardIcon
{
    return [self imageWithKey:@"chatEditForward" generator:^UIImage *{
        return [TGPresentationAssets chatForwardIcon:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)chatEditForwardDisabledIcon
{
    return [self imageWithKey:@"chatEditForwardDisabled" generator:^UIImage *{
        return [TGPresentationAssets chatForwardIcon:self.pallete.navigationDisabledButtonColor];
    }];
}

- (UIImage *)chatCallIconIncoming
{
    return [self imageWithKey:@"chatCallIn" generator:^UIImage *{
        return [TGPresentationAssets chatCallIcon:self.pallete.chatIncomingAccentColor];
    }];
}

- (UIImage *)chatCallIconOutgoing
{
    return [self imageWithKey:@"chatCallOut" generator:^UIImage *{
        return [TGPresentationAssets chatCallIcon:self.pallete.chatOutgoingAccentColor];
    }];
}

- (UIImage *)profileVerifiedIcon
{
    return [self imageWithKey:@"profileVerified" generator:^UIImage *{
        return [TGPresentationAssets profileVerifiedIcon:self.pallete.dialogVerifiedBackgroundColor color:self.pallete.dialogVerifiedIconColor];
    }];
}

- (UIImage *)profileCallIcon
{
    return [self imageWithKey:@"profileCall" generator:^UIImage *{
        return [TGPresentationAssets profileCallIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)profilePhoneDisclosureIcon
{
    return [self imageWithKey:@"profilePhoneDisclosure" generator:^UIImage *{
        return [TGPresentationAssets profilePhoneDisclosureIcon:self.pallete.collectionMenuAccessoryColor];
    }];
}

- (UIImage *)fontSizeSmallIcon
{
    return [self imageWithKey:@"fontSmall" generator:^UIImage *{
        return [TGPresentationAssets fontSizeSmallIcon:self.pallete.collectionMenuTextColor];
    }];
}

- (UIImage *)fontSizeLargeIcon
{
    return [self imageWithKey:@"fontLarge" generator:^UIImage *{
        return [TGPresentationAssets fontSizeLargeIcon:self.pallete.collectionMenuTextColor];
    }];
}

- (UIImage *)brightnessMinIcon
{
    return [self imageWithKey:@"brightnessMin" generator:^UIImage *{
        return [TGPresentationAssets brightnessMinIcon:self.pallete.collectionMenuTextColor];
    }];
}

- (UIImage *)brightnessMaxIcon
{
    return [self imageWithKey:@"brightnessMax" generator:^UIImage *{
        return [TGPresentationAssets brightnessMaxIcon:self.pallete.collectionMenuTextColor];
    }];
}

- (UIImage *)videoPlayerPlayIcon
{
    return [self imageWithKey:@"videoPlay" generator:^UIImage *{
        return [TGPresentationAssets videoPlayerPlayIcon:[UIColor whiteColor]];
    }];
}

- (UIImage *)videoPlayerPauseIcon
{
    return [self imageWithKey:@"videoPause" generator:^UIImage *{
        return [TGPresentationAssets videoPlayerPauseIcon:[UIColor whiteColor]];
    }];
}

- (UIImage *)videoPlayerForwardIcon
{
    return [self imageWithKey:@"videoForward" generator:^UIImage *{
        return [TGPresentationAssets videoPlayerForwardIcon:[UIColor whiteColor]];
    }];
}

- (UIImage *)videoPlayerBackwardIcon
{
    return [self imageWithKey:@"videoBackward" generator:^UIImage *{
        return [TGPresentationAssets videoPlayerBackwardIcon:[UIColor whiteColor]];
    }];
}

- (UIImage *)videoPlayerPIPIcon
{
    return [self imageWithKey:@"videoPIP" generator:^UIImage *{
        return [TGPresentationAssets videoPlayerPIPIcon:[UIColor whiteColor]];
    }];
}

- (UIImage *)musicPlayerRate2xIcon
{
    return [self imageWithKey:@"musicRate" generator:^UIImage *{
        return [TGPresentationAssets rate2xIcon:self.pallete.secondaryTextColor];
    }];
}

- (UIImage *)musicPlayerRate2xActiveIcon
{
    return [self imageWithKey:@"musicRate2x" generator:^UIImage *{
        return [TGPresentationAssets rate2xIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)sharedMediaInstantViewIcon
{
    return [self imageWithKey:@"sharedMediaIV" generator:^UIImage *{
        return [TGPresentationAssets chatInstantViewIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)sharedMediaDownloadIcon
{
    return [self imageWithKey:@"sharedMediaDownload" generator:^UIImage *{
        return [TGPresentationAssets sharedMediaDownloadIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)sharedMediaPauseIcon
{
    return [self imageWithKey:@"sharedMediaPause" generator:^UIImage *{
        return [TGPresentationAssets sharedMediaPauseIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)shareSearchIcon
{
    return [self imageWithKey:@"shareSearch" generator:^UIImage *{
        return [TGPresentationAssets shareSearchIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)shareExternalIcon
{
    return [self imageWithKey:@"shareExternal" generator:^UIImage *{
        return [TGPresentationAssets shareExternalIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)shareSelectionImage
{
    return [self imageWithKey:@"shareSelection" generator:^UIImage *{
        return [TGPresentationAssets shareSelectionImage:self.pallete.accentColor];
    }];
}

- (UIImage *)shareBadgeImage
{
    return [self imageWithKey:@"shareBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:22.0f color:self.pallete.accentColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)shareCloseIcon
{
    return [self imageWithKey:@"shareClose" generator:^UIImage *{
        return [TGPresentationAssets searchClearIcon:self.pallete.accentColor color:self.pallete.searchBarClearIconColor];
    }];
}

- (UIImage *)passportIcon
{
    return [self imageWithKey:@"passportIcon" generator:^UIImage *{
        return [TGPresentationAssets passportIcon:self.pallete.accentContrastColor];
    }];
}

- (UIImage *)passportScanIcon
{
    return [self imageWithKey:@"passportScanIcon" generator:^UIImage *{
        return [TGPresentationAssets passportScanIcon:self.pallete.accentColor];
    }];
}

- (UIImage *)mediaBadgeImage
{
    return [self imageWithKey:@"mediaBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:22.0f color:self.pallete.accentColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)collectionMenuDisclosureIcon
{
    return [self imageWithKey:@"colDisclosure" generator:^UIImage *{
        return [TGPresentationAssets collectionMenuDisclosureIcon:self.pallete.collectionMenuAccessoryColor];
    }];
}

- (UIImage *)collectionMenuCheckImage
{
    return [self imageWithKey:@"colCheck" generator:^UIImage *{
        return [TGPresentationAssets collectionMenuCheckIcon:self.pallete.collectionMenuCheckColor];
    }];
}

- (UIImage *)collectionMenuUnimportantCheckImage
{
    return [self imageWithKey:@"colUCheck" generator:^UIImage *{
        return [TGPresentationAssets collectionMenuCheckIcon:self.pallete.collectionMenuAccessoryColor];
    }];
}

- (UIImage *)collectionMenuAddImage
{
    return [self imageWithKey:@"colAdd" generator:^UIImage *{
        return [TGPresentationAssets collectionMenuAddIcon:self.pallete.collectionMenuAccentColor];
    }];
}

- (UIImage *)collectionMenuReorderIcon
{
    return [self imageWithKey:@"colReorder" generator:^UIImage *{
        return [TGPresentationAssets collectionMenuReorderIcon:self.pallete.collectionMenuAccessoryColor];
    }];
}

- (UIImage *)collectionMenuUnreadIcon
{
    return [self imageWithKey:@"colUnread" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:6.0f color:self.pallete.collectionMenuBadgeColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)collectionMenuBadgeImage
{
    return [self imageWithKey:@"colBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:20.0f color:self.pallete.collectionMenuBadgeColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)collectionMenuClearImage
{
    return [self imageWithKey:@"colClear" generator:^UIImage *{
        return [TGPresentationAssets searchClearIcon:self.pallete.collectionMenuPlaceholderColor color:self.pallete.collectionMenuCellBackgroundColor];
    }];
}

- (UIImage *)collectionMenuPlusImage
{
    return [self imageWithKey:@"colPlus" generator:^UIImage *{
        return [TGPresentationAssets plusMinusIcon:true backgroundColor:self.pallete.dialogEncryptedColor color:self.pallete.accentContrastColor];
    }];
}

- (UIImage *)collectionMenuMinusImage
{
    return [self imageWithKey:@"colMinus" generator:^UIImage *{
        return [TGPresentationAssets plusMinusIcon:false backgroundColor:self.pallete.destructiveColor color:self.pallete.accentContrastColor];
    }];
}

- (UIImage *)menuCornersImage
{
    return [self imageWithKey:@"menuCorners" generator:^UIImage *{
        return [TGPresentationAssets menuCornersImage:self.pallete.menuBackgroundColor];
    }];
}

- (UIImage *)menuContrastBadgeImage
{
    return [self imageWithKey:@"menuContrastBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:20.0f color:self.pallete.accentContrastColor border:0.0f borderColor:nil];
    }];
}

- (UIImage *)menuDefaultButtonImage
{
    return [self imageWithKey:@"menuDefaultButton" generator:^UIImage *{
        return [TGPresentationAssets modernButtonImageWithColor:self.pallete.menuAccentColor solid:false];
    }];
}

- (UIImage *)menuSendButtonImage
{
    return [self imageWithKey:@"menuSendButton" generator:^UIImage *{
        return [TGPresentationAssets modernButtonImageWithColor:self.pallete.menuAccentColor solid:true];
    }];
}

- (UIImage *)menuDestructiveButtonImage
{
    return [self imageWithKey:@"menuDestructiveButton" generator:^UIImage *{
        return [TGPresentationAssets modernButtonImageWithColor:self.pallete.menuDestructiveColor solid:false];
    }];
}

- (UIImage *)segmentedControlBackgroundImage
{
    return [self imageWithKey:@"segmentedBackground" generator:^UIImage *{
        return [TGPresentationAssets segmentedControlBackgroundImage:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)segmentedControlSelectedImage
{
    return [self imageWithKey:@"segmentedSelected" generator:^UIImage *{
        return [TGPresentationAssets segmentedControlSelectedImage:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)segmentedControlHighlightedImage
{
    return [self imageWithKey:@"segmentedHighlighted" generator:^UIImage *{
        return [TGPresentationAssets segmentedControlHighlightedImage:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)segmentedControlDividerImage
{
    return [self imageWithKey:@"segmentedDivider" generator:^UIImage *{
        return [TGPresentationAssets segmentedControlDividerImage:self.pallete.navigationButtonColor];
    }];
}

- (UIImage *)placeholderImage
{
    return [self imageWithKey:@"placeholderImage" generator:^UIImage *{
        return [TGPresentationAssets imageWithColor:self.pallete.backgroundColor border:1.0f borderColor:self.pallete.selectionColor];
    }];
}

- (UIImage *)avatarPlaceholderWithDiameter:(CGFloat)diameter
{
    return [self avatarPlaceholderWithDiameter:diameter color:self.pallete.backgroundColor borderColor:self.pallete.selectionColor];
}

- (UIImage *)avatarPlaceholderWithDiameter:(CGFloat)diameter color:(UIColor *)color borderColor:(UIColor *)borderColor
{
    NSString *key = [NSString stringWithFormat:@"avatarPlaceholder_%lf_%d_%d", diameter, [color hexCode], [borderColor hexCode]];
    return [self imageWithKey:key generator:^UIImage *{
        return [TGPresentationAssets avatarPlaceholderWithDiameter:diameter color:color border:1.0f borderColor:borderColor];
    }];
}

- (void)resetBubbleBackgrounds
{
    NSArray *keys = @
    [
     @"chatBubbleIncomingFull",
     @"chatBubbleIncomingPartial",
     @"chatBubbleOutgoingFull",
     @"chatBubbleOutgoingPartial",
     @"chatReplyUrl",
     @"chatReplyPhone",
     @"chatReplyLocation",
     @"chatReplySwitchInline",
     @"chatReplyAction",
     @"chatDeliveredSticker",
     @"chatReadSticker"
    ];
    
    for (NSString *key in keys)
        [_cache removeObjectForKey:key];
    
    [TGCheckButtonView resetCache];
}

#pragma mark - Common

- (instancetype)initWithPallete:(TGPresentationPallete *)pallete
{
    self = [super init];
    if (self != nil)
    {
        _pallete = pallete;
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (UIImage *)imageWithKey:(NSString *)key generator:(UIImage *(^)(void))generator
{
    UIImage *cachedImage = [_cache objectForKey:key];
    if (cachedImage != nil)
        return cachedImage;
    
    cachedImage = generator();
    NSAssert(cachedImage != nil, @"Nil image returned from generator");
    if (cachedImage == nil)
        return nil;
    
    [_cache setObject:cachedImage forKey:key];
    return cachedImage;
}

+ (instancetype)imagesWithPallete:(TGPresentationPallete *)pallete
{
    return [[TGPresentationImages alloc] initWithPallete:pallete];
}

@end
