#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLcontacts_Located : NSObject <TLObject>

@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_Located$contacts_located : TLcontacts_Located


@end

