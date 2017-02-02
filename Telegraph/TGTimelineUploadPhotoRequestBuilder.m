#import "TGTimelineUploadPhotoRequestBuilder.h"

#import <UIKit/UIKit.h>

#import <CommonCrypto/CommonDigest.h>

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGUser+Telegraph.h"
#import "TGTimelineItem.h"
#import "TGImageMediaAttachment+Telegraph.h"

#import "TGImageUtils.h"

#import "TGUserDataRequestBuilder.h"

#import "TGRemoteImageView.h"

#import "TGDatabase.h"

#import "TLUser$modernUser.h"

#import <Security/Security.h>

#import "TGAppDelegate.h"

#import "TGTelegramNetworking.h"

#define FILE_CHUNK_SIZE (16 * 1024)

@interface TGTimelineUploadPhotoRequestBuilder ()

@property (nonatomic, strong) NSString *originalFileUrl;

@property (nonatomic, strong) NSData *fileData;

@end

@implementation TGTimelineUploadPhotoRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/timeline/@/uploadPhoto/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        self.cancelTimeout = 0;
        
        NSRange range = [self.path rangeOfString:@")/uploadPhoto/"];
        int timelineId = [[self.path substringWithRange:NSMakeRange(14, range.location - 14)] intValue];
        self.requestQueueName = [NSString stringWithFormat:@"timeline/%d", timelineId];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)execute:(NSDictionary *)options
{
    _originalFileUrl = [options objectForKey:@"originalFileUrl"];
    
    NSString *tmpImagesPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"];
    static NSFileManager *fileManager = nil;
    if (fileManager == nil)
        fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileManager createDirectoryAtPath:tmpImagesPath withIntermediateDirectories:true attributes:nil error:&error];
    NSString *absoluteFilePath = [tmpImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", _originalFileUrl]];
    
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:absoluteFilePath];
    
    if (imageData == nil)
    {
        [self removeFromActionQueue];
        
        [ActionStageInstance() actionFailed:self.path reason:-1];
        
        return;
    }
    
    if (![[options objectForKey:@"restoringFromFutureAction"] boolValue])
    {
        [TGDatabaseInstance() storeFutureActions:[[NSArray alloc] initWithObjects:[[TGUploadAvatarFutureAction alloc] initWithOriginalFileUrl:_originalFileUrl latitude:0.0 longitude:0.0], nil]];
    }
    
    _currentPhoto = [options objectForKey:@"currentPhoto"];
    if (_currentPhoto == nil)
    {
        UIImage *originalImage = [[UIImage alloc] initWithData:imageData];
        
        TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:64x64"];
        UIImage *toImage = filter(originalImage);
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _currentPhoto = toImage;
        });
    }
    
    _fileData = imageData;

    static int actionId = 0;
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/upload/(userAvatar%d)", actionId++] options:[[NSDictionary alloc] initWithObjectsAndKeys:_fileData, @"data", @(TGNetworkMediaTypeTagImage), @"mediaTypeTag", nil] watcher:self];
}

- (UIImage *)currentLoginBigPhoto
{
    if (_currentLoginBigPhoto == nil)
    {
        UIImage *image = [[UIImage alloc] initWithData:_fileData];
        TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:110x110"];
        _currentLoginBigPhoto = filter(image);
    }
    
    return _currentLoginBigPhoto;
}

- (void)timelineUploadPhotoSuccess:(TLphotos_Photo *)photo
{
    [self removeFromActionQueue];
    
    TGTimelineItem *createdItem = [[TGTimelineItem alloc] initWithDescription:photo.photo];
    
    for (TLUser *userDesc in photo.users)
    {
        if (((TLUser$modernUser *)userDesc).n_id == TGTelegraphInstance.clientUserId)
        {
            TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:userDesc];
            if (user.photoUrlSmall != nil)
            {
                UIImage *originalImage = [[UIImage alloc] initWithData:_fileData];
                UIImage *scaledImage = TGScaleImageToPixelSize(originalImage, TGFitSize(originalImage.size, CGSizeMake(160, 160)));
                
                NSData *scaledData = UIImageJPEGRepresentation(scaledImage, 0.89f);
                [[TGRemoteImageView sharedCache] cacheImage:nil withData:scaledData url:user.photoUrlSmall availability:TGCacheDisk];
                
                NSData *fullData = UIImageJPEGRepresentation(TGScaleImageToPixelSize(originalImage, CGSizeMake(600, 600)), 0.6f);
                [[TGRemoteImageView sharedCache] cacheImage:nil withData:fullData url:user.photoUrlBig availability:TGCacheDisk];
            }
            break;
        }
    }
    [TGUserDataRequestBuilder executeUserDataUpdate:photo.users];
    
    [TGDatabaseInstance() clearPeerProfilePhotos:TGTelegraphInstance.clientUserId];
    
    [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:createdItem]];
}

- (void)timelineUploadPhotoFailed
{
    [self removeFromActionQueue];
    
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/upload/"])
    {
        if (status == ASStatusSuccess)
        {
            TLInputFile *inputFile = result[@"file"];
            
            self.cancelToken = [TGTelegraphInstance doUploadTimelinePhoto:inputFile hasLocation:false latitude:0.0 longitude:0.0 actor:self];
        }
        else
        {
            [self timelineUploadPhotoFailed];
        }
    }
}

- (void)cancel
{
    [self removeFromActionQueue];
    
    [ActionStageInstance() removeWatcher:self];
    
    [super cancel];
}

- (void)removeFromActionQueue
{
    NSArray *avatarActions = [TGDatabaseInstance() loadFutureActionsWithType:TGUploadAvatarFutureActionType];
    if (avatarActions.count != 0)
    {
        for (TGUploadAvatarFutureAction *action in avatarActions)
        {
            if ([action.originalFileUrl isEqualToString:_originalFileUrl])
            {
                [TGDatabaseInstance() removeFutureAction:action.uniqueId type:action.type randomId:action.randomId];
            }
        }
    }
}

@end
