#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLContactLink;
@class TLUser;

@interface TLcontacts_Link : NSObject <TLObject>

@property (nonatomic, retain) TLContactLink *my_link;
@property (nonatomic, retain) TLContactLink *foreign_link;
@property (nonatomic, retain) TLUser *user;

@end

@interface TLcontacts_Link$contacts_link : TLcontacts_Link


@end

