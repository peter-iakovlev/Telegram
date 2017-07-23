#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;
@class TLMessageMedia;
@class TLMessageFwdHeader;
@class TLReplyMarkup;

@interface TLMessage : NSObject <TLObject>

@property (nonatomic) int32_t n_id;

@end

@interface TLMessage$messageEmpty : TLMessage


@end

@interface TLMessage$message : TLMessage

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t from_id;
@property (nonatomic, retain) TLPeer *to_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLMessageMedia *media;

@end

@interface TLMessage$messageMeta : TLMessage

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t from_id;
@property (nonatomic, retain) TLPeer *to_id;
@property (nonatomic, retain) TLMessageFwdHeader *fwd_from;
@property (nonatomic) int32_t via_bot_id;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLMessageMedia *media;
@property (nonatomic, retain) TLReplyMarkup *reply_markup;
@property (nonatomic, retain) NSArray *entities;
@property (nonatomic) int32_t views;
@property (nonatomic) int32_t edit_date;
@property (nonatomic, retain) NSString *post_author;

@end

