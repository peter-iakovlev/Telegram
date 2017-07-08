#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLcontacts_ImportedContacts : NSObject <TLObject>

@property (nonatomic, retain) NSArray *imported;
@property (nonatomic, retain) NSArray *popular_invites;
@property (nonatomic, retain) NSArray *retry_contacts;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_ImportedContacts$contacts_importedContacts : TLcontacts_ImportedContacts


@end

