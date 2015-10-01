#import "TLUser.h"

#import "TLUserProfilePhoto.h"
#import "TLUserStatus.h"

@interface TLUser$modernUser : TLUser

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t n_id;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) TLUserProfilePhoto *photo;
@property (nonatomic, strong) TLUserStatus *status;
@property (nonatomic) int32_t bot_info_version;

@end
