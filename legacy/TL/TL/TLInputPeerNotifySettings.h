#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPeerNotifySettings : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) bool showPreviews;
@property (nonatomic) bool silent;
@property (nonatomic) int32_t mute_until;
@property (nonatomic, retain) NSString *sound;

@end

@interface TLInputPeerNotifySettings$inputPeerNotifySettingsMeta : TLInputPeerNotifySettings


@end

