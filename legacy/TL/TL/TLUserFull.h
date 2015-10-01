#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUser;
@class TLcontacts_Link;
@class TLPhoto;
@class TLPeerNotifySettings;
@class TLBotInfo;

@interface TLUserFull : NSObject <TLObject>

@property (nonatomic, retain) TLUser *user;
@property (nonatomic, retain) TLcontacts_Link *link;
@property (nonatomic, retain) TLPhoto *profile_photo;
@property (nonatomic, retain) TLPeerNotifySettings *notify_settings;
@property (nonatomic) bool blocked;
@property (nonatomic, retain) TLBotInfo *bot_info;

@end

@interface TLUserFull$userFull : TLUserFull


@end

