#import "TGBridgeMediaHandler.h"
#import "TGBridgeMediaSubscription.h"

#import "TGBridgeServer.h"

#import "TGImageInfo+Telegraph.h"
#import "TGMediaSignals.h"
#import "TGSharedMediaSignals.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"
#import "TGImageUtils.h"

#import "TGBridgeImageMediaAttachment+TGImageMediaAttachment.h"
#import "TGBridgeVideoMediaAttachment+TGVideoMediaAttachment.h"

@implementation TGBridgeMediaHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)server
{
    if ([subscription isKindOfClass:[TGBridgeMediaPhotoThumbnailSubscription class]])
    {
        TGBridgeMediaPhotoThumbnailSubscription *mediaSubscription = (TGBridgeMediaPhotoThumbnailSubscription *)subscription;
        
        TGImageMediaAttachment *attachment = [TGBridgeImageMediaAttachment tgImageMediaAttachmentWithBridgeImageMediaAttachment:mediaSubscription.imageAttachment];
        
        NSString *imageUrl = [attachment.imageInfo closestImageUrlWithSize:CGSizeMake(320.0f, 320.0f) resultingSize:NULL];
        return [[[TGMediaSignals photoThumbnailPathWithImageMedia:attachment targetSize:mediaSubscription.size] mapToSignal:^SSignal *(NSString *path)
        {
            [server sendFileWithURL:[NSURL fileURLWithPath:path] key:imageUrl];
            return [SSignal single:imageUrl];
        }] startOn:[SQueue concurrentDefaultQueue]];
    }
    else if ([subscription isKindOfClass:[TGBridgeMediaVideoThumbnailSubscription class]])
    {
        TGBridgeMediaVideoThumbnailSubscription *mediaSubscription = (TGBridgeMediaVideoThumbnailSubscription *)subscription;
        
        TGVideoMediaAttachment *attachment = [TGBridgeVideoMediaAttachment tgVideoMediaAttachmentWithBridgeVideoMediaAttachment:mediaSubscription.videoAttachment];
        
        NSString *imageUrl = [attachment.thumbnailInfo closestImageUrlWithSize:CGSizeMake(320.0f, 320.0f) resultingSize:NULL];
        return [[[TGMediaSignals videoThumbnailPathWithVideoMedia:attachment targetSize:mediaSubscription.size] mapToSignal:^SSignal *(NSString *path)
        {
            [server sendFileWithURL:[NSURL fileURLWithPath:path] key:imageUrl];
            return [SSignal single:imageUrl];
        }] startOn:[SQueue concurrentDefaultQueue]];
    }
    else if ([subscription isKindOfClass:[TGBridgeMediaAvatarSubscription class]])
    {
        TGBridgeMediaAvatarSubscription *mediaSubscription = (TGBridgeMediaAvatarSubscription *)subscription;
        
        TGImageFileReference *reference = [[TGImageFileReference alloc] initWithUrl:mediaSubscription.url];
        if (reference == nil)
            return [SSignal fail:nil];

        return [[[TGMediaSignals avatarPathWithReference:reference] mapToSignal:^SSignal *(NSString *path)
        {
            CGSize targetSize;
            CGFloat compressionRate = 0.5f;
            switch (mediaSubscription.type)
            {
                case TGBridgeMediaAvatarTypeSmall:
                    targetSize = CGSizeMake(19, 19);
                    compressionRate = 0.25f;
                    break;
                    
                case TGBridgeMediaAvatarTypeProfile:
                    targetSize = CGSizeMake(44, 44);
                    break;
                    
                case TGBridgeMediaAvatarTypeLarge:
                    targetSize = CGSizeMake(150, 150);
                    break;
                    
                default:
                    break;
            }
            
            NSString *key = [NSString stringWithFormat:@"%@_%lu", mediaSubscription.url, (unsigned long)mediaSubscription.type];
            NSURL *url = [NSURL fileURLWithPath:key relativeToURL:server.temporaryFilesURL];
            
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            UIImage *resizedImage = nil;
            if (mediaSubscription.type == TGBridgeMediaAvatarTypeProfile)
                resizedImage = TGScaleAndRoundCorners(image, targetSize, targetSize, 22, nil, true, [UIColor blackColor]);
            else
                resizedImage = TGScaleImage(image, targetSize);
            NSData *imageData = UIImageJPEGRepresentation(resizedImage, compressionRate);
        
            [imageData writeToURL:url atomically:true];
            [server sendFileWithURL:url key:key];

            return [SSignal single:key];
        }] startOn:[SQueue concurrentDefaultQueue]];
    }
    else if ([subscription isKindOfClass:[TGBridgeMediaStickerSubscription class]])
    {
        TGBridgeMediaStickerSubscription *mediaSubscription = (TGBridgeMediaStickerSubscription *)subscription;
        
        return [[[TGMediaSignals stickerPathWithDocumentId:mediaSubscription.documentId accessHash:mediaSubscription.accessHash legacyThumbnailUri:mediaSubscription.legacyThumbnailUri datacenterId:mediaSubscription.datacenterId size:mediaSubscription.size] mapToSignal:^SSignal *(UIImage *image)
        {
            NSData *imageData = UIImagePNGRepresentation(image);
            NSString *key = [NSString stringWithFormat:@"sticker-%lld-%dx%d", mediaSubscription.documentId, (int)mediaSubscription.size.width, (int)mediaSubscription.size.height];
            NSURL *url = [NSURL fileURLWithPath:key relativeToURL:server.temporaryFilesURL];
            [imageData writeToURL:url atomically:true];
            [server sendFileWithURL:url key:key];
            
            return [SSignal single:key];
        }] startOn:[SQueue concurrentDefaultQueue]];
    }
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeMediaPhotoThumbnailSubscription class], [TGBridgeMediaVideoThumbnailSubscription class], [TGBridgeMediaAvatarSubscription class], [TGBridgeMediaStickerSubscription class] ];
}

@end
