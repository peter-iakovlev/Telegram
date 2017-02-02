#import "TLBotInlineMessage.h"

@class TLGeoPoint;
@class TLReplyMarkup;

@interface TLBotInlineMessage$botInlineMessageMediaGeo : TLBotInlineMessage

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLGeoPoint *geo_point;
@property (nonatomic, strong) TLReplyMarkup *reply_markup;

@end
