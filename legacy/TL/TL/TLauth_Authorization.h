#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUser;

@interface TLauth_Authorization : NSObject <TLObject>

@property (nonatomic) int32_t expires;
@property (nonatomic, retain) TLUser *user;

@end

@interface TLauth_Authorization$auth_authorization : TLauth_Authorization


@end

