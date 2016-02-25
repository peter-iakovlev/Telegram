#import "TLChat.h"

@class TLChatPhoto;
@class TLInputChannel;

//chat#D91CDD54 flags:# creator:flags.0?true kicked:flags.1?true left:flags.2?true admins_enabled:flags.3?true admin:flags.4?true deactivated:flags.5?true id:int title:string photo:ChatPhoto participants_count:int date:int version:int migrated_to:flags.6?InputChannel = Chat;

@interface TLChat$chat : TLChat

@property (nonatomic) int32_t flags;

@property (nonatomic) bool creator;
@property (nonatomic) bool kicked;
@property (nonatomic) bool left;
@property (nonatomic) bool admins_enabled;
@property (nonatomic) bool admin;
@property (nonatomic) bool deactivated;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) TLChatPhoto *photo;
@property (nonatomic) int32_t participants_count;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t version;
@property (nonatomic, strong) TLInputChannel *migrated_to;

@end
