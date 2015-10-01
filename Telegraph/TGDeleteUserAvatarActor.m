#import "TGDeleteUserAvatarActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "TGRemoteImageView.h"
#import "TGImageUtils.h"

@interface TGDeleteUserAvatarActor ()
{
    int _uid;
}

@end

@implementation TGDeleteUserAvatarActor

+ (NSString *)genericPath
{
    return @"/tg/timeline/@/deleteAvatar/@";
}

- (void)prepare:(NSDictionary *)options
{
    _uid = [[options objectForKey:@"uid"] intValue];
    self.requestQueueName = [[NSString alloc] initWithFormat:@"timeline/%d", _uid];
    
    [super prepare:options];
}

- (void)execute:(NSDictionary *)__unused options
{
    self.cancelToken = [TGTelegraphInstance doAssignProfilePhoto:0 accessHash:0 actor:(TGTimelineAssignProfilePhotoActor *)self];
}

- (void)assignProfilePhotoRequestSuccess:(TLUserProfilePhoto *)photo
{
    [TGDatabaseInstance() clearPeerProfilePhotos:_uid];
    
    if ([photo isKindOfClass:[TLUserProfilePhoto$userProfilePhoto class]])
    {
        TLUserProfilePhoto$userProfilePhoto *concretePhoto = (TLUserProfilePhoto$userProfilePhoto *)photo;
        
        TGUser *originalUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
        TGUser *selfUser = [originalUser copy];
        if (selfUser != nil)
        {
            selfUser.photoUrlSmall = extractFileUrl(concretePhoto.photo_small);
            selfUser.photoUrlMedium = nil;
            selfUser.photoUrlBig = extractFileUrl(concretePhoto.photo_big);
        }
        
        NSString *url = [[NSString alloc] initWithFormat:@"{filter:%@}%@", @"profileAvatar", selfUser.photoUrlSmall];
        
        UIImage *smallOriginalImage = [[TGRemoteImageView sharedCache] cachedImage:selfUser.photoUrlSmall availability:TGCacheDisk];
        if (smallOriginalImage == nil)
        {
            UIImage *largeImage = [[TGRemoteImageView sharedCache] cachedImage:selfUser.photoUrlBig availability:TGCacheDisk];
            
            if (largeImage != nil)
            {
                smallOriginalImage = TGScaleImageToPixelSize(largeImage, CGSizeMake(160, 160));
                
                if (smallOriginalImage != nil)
                {
                    TGImageProcessor imageProcessor = [TGRemoteImageView imageProcessorForName:@"profileAvatar"];
                    if (imageProcessor != nil)
                    {
                        UIImage *smallImage = imageProcessor(smallOriginalImage);
                        if (smallOriginalImage != nil)
                        {
                            [[TGRemoteImageView sharedCache] cacheImage:smallImage withData:nil url:url availability:TGCacheMemory];
                        }
                    }
                }
                
                if (![[TGRemoteImageView sharedCache] diskCacheContainsSync:selfUser.photoUrlSmall])
                {
                    NSData *data = UIImageJPEGRepresentation(smallOriginalImage, 0.8f);
                    [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:selfUser.photoUrlSmall availability:TGCacheDisk];
                }
            }
        }
        else if ([[TGRemoteImageView sharedCache] cachedImage:url availability:TGCacheMemory] == nil)
        {
            TGImageProcessor imageProcessor = [TGRemoteImageView imageProcessorForName:@"profileAvatar"];
            if (imageProcessor != nil)
            {
                UIImage *smallImage = imageProcessor(smallOriginalImage);
                if (smallOriginalImage != nil)
                {
                    [[TGRemoteImageView sharedCache] cacheImage:smallImage withData:nil url:url availability:TGCacheMemory];
                }
            }   
        }
        
        [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:selfUser]];
    }
    else if ([photo isKindOfClass:[TLUserProfilePhoto$userProfilePhotoEmpty class]])
    {
        TGUser *originalUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
        TGUser *selfUser = [originalUser copy];
        if (selfUser != nil)
        {
            selfUser.photoUrlSmall = nil;
            selfUser.photoUrlMedium = nil;
            selfUser.photoUrlBig = nil;
        }
        
        [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:selfUser]];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)assignProfilePhotoRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
