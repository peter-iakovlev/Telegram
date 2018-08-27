#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLDataJSON;

@interface TLhelp_PassportConfig : NSObject <TLObject>

@end


@interface TLhelp_PassportConfig$help_passportConfigNotModified : TLhelp_PassportConfig

@end

@interface TLhelp_PassportConfig$help_passportConfig : TLhelp_PassportConfig

@property (nonatomic) int32_t n_hash;
@property (nonatomic, retain) TLDataJSON *countries_langs;

@end

