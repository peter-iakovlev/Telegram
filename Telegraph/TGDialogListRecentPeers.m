#import "TGDialogListRecentPeers.h"

@implementation TGDialogListRecentPeers

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title peers:(NSArray *)peers {
    self = [super init];
    if (self != nil) {
        _identifier = identifier;
        _title = title;
        _peers = peers;
    }
    return self;
}

@end
