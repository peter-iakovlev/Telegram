#import "TLChat.h"

//channel flags:# id:int access_hash:long title:string username:flags.2?string photo:ChatPhoto date:int version:int = Chat;
//channel flags:# id:int access_hash:long title:string username:flags.6?string photo:ChatPhoto date:int version:int = Chat

@class TLChatPhoto;

@interface TLChat$channel : TLChat

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) TLChatPhoto *photo;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t version;

@end
