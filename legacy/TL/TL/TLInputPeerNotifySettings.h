#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPeerNotifySettings : NSObject <TLObject>

@property (nonatomic) int32_t mute_until;
@property (nonatomic, retain) NSString *sound;
@property (nonatomic) bool show_previews;
@property (nonatomic) int32_t events_mask;

@end

@interface TLInputPeerNotifySettings$inputPeerNotifySettings : TLInputPeerNotifySettings


@end

