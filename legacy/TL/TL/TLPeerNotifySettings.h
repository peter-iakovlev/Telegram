#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPeerNotifySettings : NSObject <TLObject>


@end

@interface TLPeerNotifySettings$peerNotifySettingsEmpty : TLPeerNotifySettings


@end

@interface TLPeerNotifySettings$peerNotifySettings : TLPeerNotifySettings

@property (nonatomic) int32_t mute_until;
@property (nonatomic, retain) NSString *sound;
@property (nonatomic) bool show_previews;
@property (nonatomic) int32_t events_mask;

@end

