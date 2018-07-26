#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLDataJSON;

@interface TLhelp_TermsOfService : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLDataJSON *n_id;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSArray *entities;
@property (nonatomic) int32_t min_age_confirm;

@end

@interface TLhelp_TermsOfService$help_termsOfServiceMeta : TLhelp_TermsOfService


@end

