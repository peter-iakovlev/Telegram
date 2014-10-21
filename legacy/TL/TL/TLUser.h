#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUserProfilePhoto;
@class TLUserStatus;

@interface TLUser : NSObject <TLObject>

@property (nonatomic) int32_t n_id;

@end

@interface TLUser$userEmpty : TLUser


@end

@interface TLUser$userSelf : TLUser

@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) TLUserProfilePhoto *photo;
@property (nonatomic, retain) TLUserStatus *status;
@property (nonatomic) bool inactive;

@end

@interface TLUser$userContact : TLUser

@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) TLUserProfilePhoto *photo;
@property (nonatomic, retain) TLUserStatus *status;

@end

@interface TLUser$userRequest : TLUser

@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) TLUserProfilePhoto *photo;
@property (nonatomic, retain) TLUserStatus *status;

@end

@interface TLUser$userForeign : TLUser

@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic) int64_t access_hash;
@property (nonatomic, retain) TLUserProfilePhoto *photo;
@property (nonatomic, retain) TLUserStatus *status;

@end

@interface TLUser$userDeleted : TLUser

@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *username;

@end

