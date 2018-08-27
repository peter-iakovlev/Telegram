#import "TGMediaOriginInfo+Telegraph.h"

#import "TLMetaScheme.h"

@implementation TGMediaOriginInfo (Telegraph)

+ (instancetype)mediaOriginInfoForPhoto:(TLPhoto *)desc
{
    if ([desc isKindOfClass:[TLPhoto$photo class]])
    {
        TLPhoto$photo *photo = (TLPhoto$photo *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        for (TLPhotoSize$photoSize *size in photo.sizes)
        {
            if (![size respondsToSelector:@selector(location)])
                continue;
            
            TLFileLocation *location = [size performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        return [TGMediaOriginInfo mediaOriginInfoWithFileReference:photo.file_reference fileReferences:fileReferences];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForPhoto:(TLPhoto *)desc cid:(int64_t)cid mid:(int32_t)mid
{
    if ([desc isKindOfClass:[TLPhoto$photo class]])
    {
        TLPhoto$photo *photo = (TLPhoto$photo *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        for (TLPhotoSize$photoSize *size in photo.sizes)
        {
            if (![size respondsToSelector:@selector(location)])
                continue;
            
            TLFileLocation *location = [size performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        return [TGMediaOriginInfo mediaOriginInfoWithFileReference:photo.file_reference fileReferences:fileReferences cid:cid mid:mid];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForPhoto:(TLPhoto *)desc webpageUrl:(NSString *)webpageUrl
{
    if ([desc isKindOfClass:[TLPhoto$photo class]])
    {
        TLPhoto$photo *photo = (TLPhoto$photo *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        for (TLPhotoSize$photoSize *size in photo.sizes)
        {
            if (![size respondsToSelector:@selector(location)])
                continue;
            
            TLFileLocation *location = [size performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        return [TGMediaOriginInfo mediaOriginInfoWithFileReference:photo.file_reference fileReferences:fileReferences url:webpageUrl];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForDocument:(TLDocument *)desc
{
    if ([desc isKindOfClass:[TLDocument$document class]])
    {
        TLDocument$document *document = (TLDocument$document *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        if ([document.thumb respondsToSelector:@selector(location)])
        {
            TLFileLocation *location = [document.thumb performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        fileReferences[[NSString stringWithFormat:@"%lld_%lld", document.n_id, document.access_hash]] = document.file_reference;
        
        return [TGMediaOriginInfo mediaOriginInfoWithFileReference:document.file_reference fileReferences:fileReferences];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForDocument:(TLDocument *)desc cid:(int64_t)cid mid:(int32_t)mid
{
    if ([desc isKindOfClass:[TLDocument$document class]])
    {
        TLDocument$document *document = (TLDocument$document *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        if ([document.thumb respondsToSelector:@selector(location)])
        {
            TLFileLocation *location = [document.thumb performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        fileReferences[[NSString stringWithFormat:@"%lld_%lld", document.n_id, document.access_hash]] = document.file_reference;
        
        return [TGMediaOriginInfo mediaOriginInfoWithFileReference:document.file_reference fileReferences:fileReferences cid:cid mid:mid];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForDocument:(TLDocument *)desc stickerPackId:(int64_t)stickerPackId stickerPackAccessHash:(int64_t)stickerPackAccessHash
{
    if ([desc isKindOfClass:[TLDocument$document class]])
    {
        TLDocument$document *document = (TLDocument$document *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        if ([document.thumb respondsToSelector:@selector(location)])
        {
            TLFileLocation *location = [document.thumb performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        fileReferences[[NSString stringWithFormat:@"%lld_%lld", document.n_id, document.access_hash]] = document.file_reference;
        
        return [TGMediaOriginInfo mediaOriginInfoWithFileReference:document.file_reference fileReferences:fileReferences stickerPackId:stickerPackId accessHash:stickerPackAccessHash];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForDocumentRecentSticker:(TLDocument *)desc
{
    if ([desc isKindOfClass:[TLDocument$document class]])
    {
        TLDocument$document *document = (TLDocument$document *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        if ([document.thumb respondsToSelector:@selector(location)])
        {
            TLFileLocation *location = [document.thumb performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        fileReferences[[NSString stringWithFormat:@"%lld_%lld", document.n_id, document.access_hash]] = document.file_reference;
        
        return [TGMediaOriginInfo mediaOriginInfoForRecentStickerWithFileReference:document.file_reference fileReferences:fileReferences];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForDocumentRecentMask:(TLDocument *)desc
{
    if ([desc isKindOfClass:[TLDocument$document class]])
    {
        TLDocument$document *document = (TLDocument$document *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        if ([document.thumb respondsToSelector:@selector(location)])
        {
            TLFileLocation *location = [document.thumb performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        fileReferences[[NSString stringWithFormat:@"%lld_%lld", document.n_id, document.access_hash]] = document.file_reference;
        
        return [TGMediaOriginInfo mediaOriginInfoForRecentMaskWithFileReference:document.file_reference fileReferences:fileReferences];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForDocumentFavoriteSticker:(TLDocument *)desc
{
    if ([desc isKindOfClass:[TLDocument$document class]])
    {
        TLDocument$document *document = (TLDocument$document *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        if ([document.thumb respondsToSelector:@selector(location)])
        {
            TLFileLocation *location = [document.thumb performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        fileReferences[[NSString stringWithFormat:@"%lld_%lld", document.n_id, document.access_hash]] = document.file_reference;
        
        return [TGMediaOriginInfo mediaOriginInfoForFavoriteStickerWithFileReference:document.file_reference fileReferences:fileReferences];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForDocumentRecentGif:(TLDocument *)desc
{
    if ([desc isKindOfClass:[TLDocument$document class]])
    {
        TLDocument$document *document = (TLDocument$document *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        if ([document.thumb respondsToSelector:@selector(location)])
        {
            TLFileLocation *location = [document.thumb performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        fileReferences[[NSString stringWithFormat:@"%lld_%lld", document.n_id, document.access_hash]] = document.file_reference;
        
        return [TGMediaOriginInfo mediaOriginInfoForRecentGifWithFileReference:document.file_reference fileReferences:fileReferences];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForDocument:(TLDocument *)desc webpageUrl:(NSString *)webpageUrl
{
    if ([desc isKindOfClass:[TLDocument$document class]])
    {
        TLDocument$document *document = (TLDocument$document *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        if ([document.thumb respondsToSelector:@selector(location)])
        {
            TLFileLocation *location = [document.thumb performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        fileReferences[[NSString stringWithFormat:@"%lld_%lld", document.n_id, document.access_hash]] = document.file_reference;
        
        return [TGMediaOriginInfo mediaOriginInfoWithFileReference:document.file_reference fileReferences:fileReferences url:webpageUrl];
    }
    
    return nil;
}

+ (instancetype)mediaOriginInfoForWallpaper:(TLWallPaper *)desc
{
    if ([desc isKindOfClass:[TLWallPaper$wallPaper class]])
    {
        TLWallPaper$wallPaper *wallpaper = (TLWallPaper$wallPaper *)desc;
        
        NSMutableDictionary *fileReferences = [[NSMutableDictionary alloc] init];
        for (TLPhotoSize$photoSize *size in wallpaper.sizes)
        {
            if (![size respondsToSelector:@selector(location)])
                continue;
            
            TLFileLocation *location = [size performSelector:@selector(location)];
            if ([location isKindOfClass:[TLFileLocation$fileLocation class]])
            {
                TLFileLocation$fileLocation *fileLocation = (TLFileLocation$fileLocation *)location;
                fileReferences[[NSString stringWithFormat:@"%lld_%d", fileLocation.volume_id, fileLocation.local_id]] = fileLocation.file_reference;
            }
        }
        
        return [TGMediaOriginInfo mediaOriginInfoWithFileReferences:fileReferences wallpaperId:wallpaper.n_id];
    }
    
    return nil;
}

@end
