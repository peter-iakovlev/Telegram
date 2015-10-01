#import "TGViewController.h"

@class GDFileManager, GDURLMetadata;

@interface TGGoogleDriveDirectoryController : TGViewController

@property (nonatomic, copy) void(^cancelPressed)(void);
@property (nonatomic, copy) void(^logoutPressed)(void);

@property (nonatomic, copy) void(^filePicked)(GDURLMetadata *);

@property (nonatomic, strong) NSURL *directoryUrl;

- (instancetype)initWithFileManager:(GDFileManager *)fileManager;
- (instancetype)initWithFileManager:(GDFileManager *)fileManager url:(NSURL *)directoryUrl metadata:(GDURLMetadata *)metadata;

- (void)reloadData;

@end
