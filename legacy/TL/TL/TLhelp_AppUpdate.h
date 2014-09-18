#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLhelp_AppUpdate : NSObject <TLObject>


@end

@interface TLhelp_AppUpdate$help_appUpdate : TLhelp_AppUpdate

@property (nonatomic) int32_t n_id;
@property (nonatomic) bool critical;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *text;

@end

@interface TLhelp_AppUpdate$help_noAppUpdate : TLhelp_AppUpdate


@end

