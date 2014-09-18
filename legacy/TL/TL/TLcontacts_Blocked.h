#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLcontacts_Blocked : NSObject <TLObject>

@property (nonatomic, retain) NSArray *blocked;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_Blocked$contacts_blocked : TLcontacts_Blocked


@end

@interface TLcontacts_Blocked$contacts_blockedSlice : TLcontacts_Blocked

@property (nonatomic) int32_t count;

@end

