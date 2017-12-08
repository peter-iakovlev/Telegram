#import <Foundation/Foundation.h>

#define IMAGE @property (nonatomic, readonly) UIImage *

@class TGPresentationPallete;

@interface TGPresentationImages : NSObject

+ (instancetype)imagesWithPallete:(TGPresentationPallete *)pallete;

IMAGE tabBarContactsIcon;
IMAGE tabBarCallsIcon;
IMAGE tabBarChatsIcon;
IMAGE tabBarSettingsIcon;
IMAGE tabBarBadgeImage;

IMAGE dialogMutedIcon;
IMAGE dialogVerifiedIcon;
IMAGE dialogEncryptedIcon;
IMAGE dialogDeliveredIcon;
IMAGE dialogReadIcon;
IMAGE dialogPendingIcon;
IMAGE dialogUnsentIcon;
IMAGE dialogPinnedIcon;
IMAGE dialogMentionedIcon;
IMAGE dialogBadgeImage;
IMAGE dialogMutedBadgeImage;

IMAGE callsNewIcon;
IMAGE callsInfoIcon;
IMAGE callsOutgoingIcon;

IMAGE chatCallIconIncoming;
IMAGE chatCallIconOutgoing;

IMAGE chatDeliveredIcon;
IMAGE chatDeliveredIconMedia;
IMAGE chatReadIcon;
IMAGE chatReadIconMedia;

IMAGE chatNavBadgeImage;

IMAGE profileVerifiedIcon;
IMAGE profileCallIcon;



IMAGE collectionMenuDisclosureIcon;
IMAGE collectionMenuCheckImage;
IMAGE collectionMenuReorderIcon;
IMAGE collectionMenuUnreadIcon;
IMAGE collectionMenuBadgeImage;

@end

#undef IMAGE
