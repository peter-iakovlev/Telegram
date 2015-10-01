#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;
@class TLPeerNotifySettings;

@interface TLDialog : NSObject <TLObject>

@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic) int32_t top_message;
@property (nonatomic) int32_t read_inbox_max_id;
@property (nonatomic) int32_t unread_count;
@property (nonatomic, retain) TLPeerNotifySettings *notify_settings;

@end

@interface TLDialog$dialog : TLDialog


@end

@interface TLDialog$dialogChannel : TLDialog

@property (nonatomic) int32_t top_important_message;
@property (nonatomic) int32_t unread_important_count;
@property (nonatomic) int32_t pts;

@end

