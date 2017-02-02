#import "TLBotInlineMessage.h"

@class TLGeoPoint;
@class TLReplyMarkup;

@interface TLBotInlineMessage$botInlineMessageMediaVenue : TLBotInlineMessage

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLGeoPoint *geo_point;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *provider;
@property (nonatomic, strong) NSString *venue_id;
@property (nonatomic, strong) TLReplyMarkup *reply_markup;

@end
