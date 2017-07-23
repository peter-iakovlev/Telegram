#import "TGGoogleDriveController.h"

#import "TGAlertView.h"

#import "TGGoogleDriveAuthController.h"
#import "TGGoogleDriveDirectoryController.h"

#import "TGGoogleDriveItem.h"

#import "GDFileManager.h"
#import "GDFileServiceManager.h"
#import "GDGoogleDriveFileService.h"
#import "GDGoogleDriveFileServiceSession.h"
#import "GDGoogleDriveURLMetadata.h"

NSString *const TGGoogleDriveAppKey = @"868819115263-freie45o4od3n0lr2or6ahe7p7qn2ot3.apps.googleusercontent.com";
NSString *const TGGoogleDriveAppSecret = @"0_auNUxXAOmt_CtRTmIQGTpm";

@interface TGGoogleDriveController ()
{
    GDGoogleDriveFileService *_service;
    GDGoogleDriveFileServiceSession *_session;
    
    GDFileManager *_fileManager;
}
@end

@implementation TGGoogleDriveController

- (instancetype)init
{
    GDFileManager *fileManager = [[GDFileManager alloc] init];
    TGGoogleDriveDirectoryController *rootViewController = [[TGGoogleDriveDirectoryController alloc] initWithFileManager:fileManager];
    
    self = [super initWithRootViewController:rootViewController];
    if (self != nil)
    {
        _fileManager = fileManager;
        
        for (GDFileService *fileService in [[GDFileServiceManager sharedManager] allFileServices])
        {
            if ([fileService isKindOfClass:[GDGoogleDriveFileService class]])
            {
                _service = (GDGoogleDriveFileService *)fileService;
                break;
            }
        }
        
        for (GDGoogleDriveFileServiceSession *session in _service.fileServiceSessions)
        {
            if (session.isUserVisible)
            {
                _session = session;
                break;
            }
        }
        
        __weak TGGoogleDriveController *weakSelf = self;
        rootViewController.cancelPressed = ^
        {
            __strong TGGoogleDriveController *strongSelf = weakSelf;
            if (strongSelf.dismiss != nil)
                strongSelf.dismiss();
        };
        
        rootViewController.logoutPressed = ^
        {
            __strong TGGoogleDriveController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
                
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"GoogleDrive.LogoutTitle") message:TGLocalized(@"GoogleDrive.LogoutMessage") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"GoogleDrive.LogoutLogout") completionBlock:^(bool okButtonPressed)
            {
                if (okButtonPressed)
                {
                    [strongSelf->_service unlinkSession:_session];
                    strongSelf->_session = nil;
                    
                    if (strongSelf.dismiss != nil)
                        strongSelf.dismiss();
                }
            }] show];
        };
        
        rootViewController.filePicked = ^(GDURLMetadata *metadata)
        {
            __strong TGGoogleDriveController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            GDGoogleDriveURLMetadata *driveUrlMetadata = metadata.driveMetadata;
            GDGoogleDriveMetadata *gdMetadata = nil;
            if (driveUrlMetadata != nil)
                gdMetadata = driveUrlMetadata.metadata;
            
            TGGoogleDriveItem *item = [TGGoogleDriveItem googleDriveItemWithMetadata:gdMetadata];
            if (strongSelf.filePicked != nil)
                strongSelf.filePicked(item);
            
            if (strongSelf.dismiss != nil)
                strongSelf.dismiss();
        };
    }
    return self;
}

+ (void)load
{
    [GDGoogleDriveAPIToken registerTokenWithKey:TGGoogleDriveAppKey
                                         secret:TGGoogleDriveAppSecret];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self isAuthorized])
        [self openAuthorization];
    else
        [self rootDirectoryController].directoryUrl = [_session canonicalURLForURL:[_session baseURL]];
}

- (TGGoogleDriveDirectoryController *)rootDirectoryController
{
    return (TGGoogleDriveDirectoryController *)self.viewControllers.firstObject;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)openAuthorization
{
    __weak TGGoogleDriveController *weakSelf = self;
    TGGoogleDriveAuthController *controller = [[TGGoogleDriveAuthController alloc] initWithService:_service completion:^(GDGoogleDriveClient *client, NSError *error)
    {
        __strong TGGoogleDriveController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (client != nil && error == nil)
        {
            GDGoogleDriveFileServiceSession *session = [[GDGoogleDriveFileServiceSession alloc] initWithFileService:strongSelf->_service client:client];
            [strongSelf->_service addFileServiceSession:session];
            
            strongSelf->_session = session;
            
            [strongSelf rootDirectoryController].directoryUrl = [session canonicalURLForURL:[session baseURL]];
            [strongSelf popToRootViewControllerAnimated:true];
        }
    }];
    controller.dismissBlock = ^
    {
        __strong TGGoogleDriveController *strongSelf = weakSelf;
        if (strongSelf.dismiss != nil)
            strongSelf.dismiss();
    };
    [self pushViewController:controller animated:false];
}

+ (void)unlinkCurrentSession
{
    for (GDFileService *fileService in [[GDFileServiceManager sharedManager] allFileServices])
    {
        if ([fileService isKindOfClass:[GDGoogleDriveFileService class]])
        {
            GDGoogleDriveFileService *service = (GDGoogleDriveFileService *)fileService;
            for (GDGoogleDriveFileServiceSession *session in service.fileServiceSessions)
                [service unlinkSession:session];
        }
    }
}

+ (NSString *)accessToken
{
    for (GDFileService *fileService in [[GDFileServiceManager sharedManager] allFileServices])
    {
        if ([fileService isKindOfClass:[GDGoogleDriveFileService class]])
        {
            GDGoogleDriveFileService *service = (GDGoogleDriveFileService *)fileService;
            for (GDGoogleDriveFileServiceSession *session in service.fileServiceSessions)
                return session.client.credential.oauthCredential.accessToken;
        }
    }
    
    return nil;
}

- (bool)isAuthorized
{
    return _session != nil;
}

+ (bool)isGoogleDriveInstalled
{
    return false; //[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googledrive://"]];
}

@end
