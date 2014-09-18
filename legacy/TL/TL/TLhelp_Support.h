#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUser;

@interface TLhelp_Support : NSObject <TLObject>

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) TLUser *user;

@end

@interface TLhelp_Support$help_support : TLhelp_Support


@end

