#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLMessageMedia;

@interface TLhelp_AppChangelog : NSObject <TLObject>


@end

@interface TLhelp_AppChangelog$help_appChangelogEmpty : TLhelp_AppChangelog


@end

@interface TLhelp_AppChangelog$help_appChangelog : TLhelp_AppChangelog

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLMessageMedia *media;
@property (nonatomic, retain) NSArray *entities;

@end

