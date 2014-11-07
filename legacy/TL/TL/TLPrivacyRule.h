#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPrivacyRule : NSObject <TLObject>


@end

@interface TLPrivacyRule$privacyValueAllowContacts : TLPrivacyRule


@end

@interface TLPrivacyRule$privacyValueAllowAll : TLPrivacyRule


@end

@interface TLPrivacyRule$privacyValueAllowUsers : TLPrivacyRule

@property (nonatomic, retain) NSArray *users;

@end

@interface TLPrivacyRule$privacyValueDisallowContacts : TLPrivacyRule


@end

@interface TLPrivacyRule$privacyValueDisallowAll : TLPrivacyRule


@end

@interface TLPrivacyRule$privacyValueDisallowUsers : TLPrivacyRule

@property (nonatomic, retain) NSArray *users;

@end

