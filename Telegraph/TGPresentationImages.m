#import "TGPresentationImages.h"
#import "TGPresentationPallete.h"
#import "TGPresentationAssets.h"

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
        return [TGPresentationAssets tabBarChatsIcon:self.pallete.tabIconColor];
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

- (UIImage *)chatNavBadgeImage
{
    return [self imageWithKey:@"chatNavBadge" generator:^UIImage *{
        return [TGPresentationAssets badgeWithDiameter:17.0f color:self.pallete.navigationBadgeColor border:1.0f borderColor:self.pallete.navigationBadgeBorderColor];
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
    [_cache setObject:cachedImage forKey:key];
    return cachedImage;
}

+ (instancetype)imagesWithPallete:(TGPresentationPallete *)pallete
{
    return [[TGPresentationImages alloc] initWithPallete:pallete];
}

@end
