#import "TGViewController.h"

@class GDGoogleDriveClient, GDGoogleDriveFileService;

@interface TGGoogleDriveAuthController : TGViewController

@property (nonatomic, copy) void(^dismissBlock)(void);

- (instancetype)initWithService:(GDGoogleDriveFileService *)service completion:(void (^)(GDGoogleDriveClient *client, NSError *error))completion;

@end
