#import "TGNavigationController.h"

@class TGGoogleDriveItem;

@interface TGGoogleDriveController : TGNavigationController

@property (nonatomic, copy) void(^dismiss)(void);
@property (nonatomic, copy) void(^filePicked)(TGGoogleDriveItem *item);

+ (void)unlinkCurrentSession;
+ (NSString *)accessToken;

+ (bool)isGoogleDriveInstalled;

@end

extern NSString *const TGGoogleDriveAppKey;
extern NSString *const TGGoogleDriveAppSecret;
