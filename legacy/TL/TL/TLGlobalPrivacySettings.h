#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLGlobalPrivacySettings : NSObject <TLObject>

@property (nonatomic) bool no_suggestions;
@property (nonatomic) bool hide_contacts;
@property (nonatomic) bool hide_located;
@property (nonatomic) bool hide_last_visit;

@end

@interface TLGlobalPrivacySettings$globalPrivacySettings : TLGlobalPrivacySettings


@end

