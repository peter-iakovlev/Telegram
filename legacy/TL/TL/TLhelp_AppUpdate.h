#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLDocument;

@interface TLhelp_AppUpdate : NSObject <TLObject>


@end

@interface TLhelp_AppUpdate$help_appUpdateMeta : TLhelp_AppUpdate

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t n_id;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSArray *entities;
@property (nonatomic, retain) TLDocument *document;
@property (nonatomic, retain) NSString *url;

@end

@interface TLhelp_AppUpdate$help_noAppUpdate : TLhelp_AppUpdate


@end

