#import "TGTable.h"

@implementation TGTable

- (instancetype)initWithInterface:(TGDatabaseInterface *)interface {
    self = [super init];
    if (self != nil) {
        _interface = interface;
    }
    return self;
}

@end
