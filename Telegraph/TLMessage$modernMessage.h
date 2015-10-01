#import "TLMessage.h"

@class TLReplyMarkup;
@class TLPeer;

@interface TLMessage$modernMessage : TLMessage

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t from_id;
@property (nonatomic, retain) TLPeer *to_id;
@property (nonatomic) TLPeer *fwd_from_id;
@property (nonatomic) int32_t fwd_date;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLMessageMedia *media;
@property (nonatomic, retain) TLReplyMarkup *replyMarkup;
@property (nonatomic, retain) NSArray *entities;
@property (nonatomic) int32_t views;

@end
