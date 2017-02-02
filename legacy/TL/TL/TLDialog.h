#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;
@class TLPeerNotifySettings;
@class TLDraftMessage;

@interface TLDialog : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic) int32_t top_message;
@property (nonatomic) int32_t read_inbox_max_id;
@property (nonatomic) int32_t read_outbox_max_id;
@property (nonatomic) int32_t unread_count;
@property (nonatomic, retain) TLPeerNotifySettings *notify_settings;
@property (nonatomic) int32_t pts;
@property (nonatomic, retain) TLDraftMessage *draft;

@end

@interface TLDialog$dialogMeta : TLDialog


@end

