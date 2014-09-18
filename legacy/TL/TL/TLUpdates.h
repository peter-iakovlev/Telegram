#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdate;

@interface TLUpdates : NSObject <TLObject>


@end

@interface TLUpdates$updatesTooLong : TLUpdates


@end

@interface TLUpdates$updateShortMessage : TLUpdates

@property (nonatomic) int32_t n_id;
@property (nonatomic) int32_t from_id;
@property (nonatomic, retain) NSString *message;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t seq;

@end

@interface TLUpdates$updateShortChatMessage : TLUpdates

@property (nonatomic) int32_t n_id;
@property (nonatomic) int32_t from_id;
@property (nonatomic) int32_t chat_id;
@property (nonatomic, retain) NSString *message;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t seq;

@end

@interface TLUpdates$updateShort : TLUpdates

@property (nonatomic, retain) TLUpdate *update;
@property (nonatomic) int32_t date;

@end

@interface TLUpdates$updatesCombined : TLUpdates

@property (nonatomic, retain) NSArray *updates;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t seq_start;
@property (nonatomic) int32_t seq;

@end

@interface TLUpdates$updates : TLUpdates

@property (nonatomic, retain) NSArray *updates;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t seq;

@end

