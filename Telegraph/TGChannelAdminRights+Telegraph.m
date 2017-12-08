#import "TGChannelAdminRights+Telegraph.h"

@implementation TGChannelAdminRights (TL)

- (instancetype)initWithTL:(TLChannelAdminRights *)rights {
    return [self initWithFlags:rights.flags];
}

- (TLChannelAdminRights *)tlRights {
    TLChannelAdminRights$channelAdminRights *result = [[TLChannelAdminRights$channelAdminRights alloc] init];
    result.flags = [self tlFlags];
    return result;
}

@end
