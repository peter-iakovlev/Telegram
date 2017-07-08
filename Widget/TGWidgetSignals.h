#import <SSignalKit/SSignalKit.h>

@class TGShareContext;
@class TGLegacyUser;

@interface TGWidgetSignals : NSObject

+ (SSignal *)topPeersSignal;
+ (SSignal *)userAvatarWithContext:(TGShareContext *)context user:(TGLegacyUser *)user;

@end
