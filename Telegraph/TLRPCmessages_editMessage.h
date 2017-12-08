#import <Foundation/Foundation.h>

#import "TLMetaRpc.h"
#import "TLObject.h"

#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLInputGeoPoint;

//messages.editMessage flags:# no_webpage:flags.1?true stop_geo_live:flags.12?true peer:InputPeer id:int message:flags.11?string reply_markup:flags.2?ReplyMarkup entities:flags.3?Vector<MessageEntity> geo_point:flags.13?InputGeoPoint = Updates;

@interface TLRPCmessages_editMessage : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) bool no_webpage;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic) int32_t n_id;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *entities;
@property (nonatomic, strong) TLInputGeoPoint *geo_point;

@end
