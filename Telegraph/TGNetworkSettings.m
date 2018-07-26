#import "TGNetworkSettings.h"

@implementation TGNetworkSettings

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithReducedBackupDiscoveryTimeout:[aDecoder decodeBoolForKey:@"reducedBackupDiscoveryTimeout"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:_reducedBackupDiscoveryTimeout forKey:@"reducedBackupDiscoveryTimeout"];
}

- (instancetype)initWithReducedBackupDiscoveryTimeout:(bool)reducedBackupDiscoveryTimeout {
    self = [super init];
    if (self != nil) {
        _reducedBackupDiscoveryTimeout = reducedBackupDiscoveryTimeout;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[TGNetworkSettings class]]) {
        return false;
    }
    TGNetworkSettings *other = object;
    if (_reducedBackupDiscoveryTimeout != other->_reducedBackupDiscoveryTimeout) {
        return false;
    }
    return true;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone {
    return self;
}

@end
