#import "TGUserAvatarGalleryModel.h"

#import "TGUserAvatarGalleryItem.h"

#import "ActionStage.h"

#import "TGImageMediaAttachment.h"

@interface TGUserAvatarGalleryModel () <ASWatcher>
{
    int64_t _peerId;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGUserAvatarGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId currentAvatarLegacyThumbnailImageUri:(NSString *)currentAvatarLegacyThumbnailImageUri currentAvatarLegacyImageUri:(NSString *)currentAvatarLegacyImageUri currentAvatarImageSize:(CGSize)currentAvatarImageSize
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _peerId = peerId;
        
        TGUserAvatarGalleryItem *item = [self itemForImageId:0 accessHash:0 legacyThumbnailUrl:currentAvatarLegacyThumbnailImageUri legacyUrl:currentAvatarLegacyImageUri imageSize:currentAvatarImageSize];
        [self _replaceItems:@[item] focusingOnItem:item];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)_transitionCompleted
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() watchForPath:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%" PRId64 ")", _peerId] watcher:self];
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%" PRId64 ",cached)", _peerId] options:@{@"peerId": @(_peerId)} flags:0 watcher:self];
    }];
}

- (TGUserAvatarGalleryItem *)itemForImageId:(int64_t)__unused imageId accessHash:(int64_t)__unused accessHash legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize
{
    return [[TGUserAvatarGalleryItem alloc] initWithLegacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:imageSize];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/profilePhotos/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/profilePhotos/"])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess && ((NSArray *)result).count != 0)
            {
                NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
                for (TGImageMediaAttachment *imageMedia in result)
                {
                    NSString *legacyThumbnailUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                    NSString *legacyUrl = [imageMedia.imageInfo imageUrlForLargestSize:NULL];
                    TGUserAvatarGalleryItem *item = [self itemForImageId:imageMedia.imageId accessHash:imageMedia.accessHash legacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:CGSizeMake(640.0f, 640.0f)];
                    [updatedItems addObject:item];
                }
                
                [self _replaceItems:updatedItems focusingOnItem:nil];
            }
        });
    }
}

@end
