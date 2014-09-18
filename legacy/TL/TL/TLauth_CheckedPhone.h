#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLauth_CheckedPhone : NSObject <TLObject>

@property (nonatomic) bool phone_registered;
@property (nonatomic) bool phone_invited;

@end

@interface TLauth_CheckedPhone$auth_checkedPhone : TLauth_CheckedPhone


@end

