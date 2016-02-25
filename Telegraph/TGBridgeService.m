#import "TGBridgeService.h"

@implementation TGBridgeService

- (instancetype)initWithServer:(TGBridgeServer *)server
{
    self = [self init];
    if (self != nil)
    {
        self.server = server;
    }
    return self;
}

@end
