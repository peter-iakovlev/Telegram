#import "TGUpdateAppInfo.h"

#import "TLhelp_AppUpdate$help_appUpdate.h"
#import "TGMessage+Telegraph.h"
#import "TGDocumentMediaAttachment+Telegraph.h"

@implementation TGUpdateAppInfo

- (instancetype)initWithTL:(TLhelp_AppUpdate$help_appUpdateMeta *)update
{
    self = [super init];
    if (self != nil)
    {
        _popup = update.flags & (1 << 0);
        _version = update.version;
        _text = update.text;
        _entities = [TGMessage parseTelegraphEntities:update.entities];
    }
    return self;
}

@end
