#import "TLBotInlineResult.h"

@class TLPhoto;
@class TLDocument;
@class TLBotInlineMessage;

@interface TLBotInlineResult$botInlineMediaResult : TLBotInlineResult

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) NSString *n_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) TLPhoto *photo;
@property (nonatomic, strong) TLDocument *document;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *n_description;
@property (nonatomic, strong) TLBotInlineMessage *send_message;

@end
