#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLcontacts_Contacts : NSObject <TLObject>


@end

@interface TLcontacts_Contacts$contacts_contacts : TLcontacts_Contacts

@property (nonatomic, retain) NSArray *contacts;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_Contacts$contacts_contactsNotModified : TLcontacts_Contacts


@end

