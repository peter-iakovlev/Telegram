#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPrivacyRule : NSObject <TLObject>


@end

@interface TLInputPrivacyRule$inputPrivacyValueAllowContacts : TLInputPrivacyRule


@end

@interface TLInputPrivacyRule$inputPrivacyValueAllowAll : TLInputPrivacyRule


@end

@interface TLInputPrivacyRule$inputPrivacyValueAllowUsers : TLInputPrivacyRule

@property (nonatomic, retain) NSArray *users;

@end

@interface TLInputPrivacyRule$inputPrivacyValueDisallowContacts : TLInputPrivacyRule


@end

@interface TLInputPrivacyRule$inputPrivacyValueDisallowAll : TLInputPrivacyRule


@end

@interface TLInputPrivacyRule$inputPrivacyValueDisallowUsers : TLInputPrivacyRule

@property (nonatomic, retain) NSArray *users;

@end

