#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;
@class TLPeerNotifySettings;

@interface TLDialog : NSObject <TLObject>

@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic) int32_t top_message;
@property (nonatomic) int32_t unread_count;
@property (nonatomic, retain) TLPeerNotifySettings *notify_settings;

@end

@interface TLDialog$dialog : TLDialog


@end

