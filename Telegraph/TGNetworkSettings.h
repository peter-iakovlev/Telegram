#import <Foundation/Foundation.h>

@interface TGNetworkSettings : NSObject <NSCoding>

@property (nonatomic, readonly) bool reducedBackupDiscoveryTimeout;

- (instancetype)initWithReducedBackupDiscoveryTimeout:(bool)reducedBackupDiscoveryTimeout;

@end
