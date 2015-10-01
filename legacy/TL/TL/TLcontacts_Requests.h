#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLcontacts_Requests : NSObject <TLObject>

@property (nonatomic, retain) NSArray *requests;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_Requests$contacts_requests : TLcontacts_Requests


@end

@interface TLcontacts_Requests$contacts_requestsSlice : TLcontacts_Requests

@property (nonatomic) int32_t count;

@end

