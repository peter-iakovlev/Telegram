#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;

@interface TLNotifyPeer : NSObject <TLObject>


@end

@interface TLNotifyPeer$notifyPeer : TLNotifyPeer

@property (nonatomic, retain) TLPeer *peer;

@end

@interface TLNotifyPeer$notifyUsers : TLNotifyPeer


@end

@interface TLNotifyPeer$notifyChats : TLNotifyPeer


@end

@interface TLNotifyPeer$notifyAll : TLNotifyPeer


@end

