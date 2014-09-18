#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLcontacts_Suggested : NSObject <TLObject>

@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_Suggested$contacts_suggested : TLcontacts_Suggested


@end

