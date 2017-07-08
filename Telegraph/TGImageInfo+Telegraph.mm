#import "TGImageInfo+Telegraph.h"

#import "TGSchema.h"

#import "TGCache.h"
#import "TGRemoteImageView.h"

#import "TGImageUtils.h"

NSString *extractFileUrl(id fileLocation)
{
    if ([fileLocation isKindOfClass:[TLFileLocation$fileLocation class]])
    {
        TLFileLocation$fileLocation *concreteFileLocation = (TLFileLocation$fileLocation *)fileLocation;
        
        return [[NSString alloc] initWithFormat:@"%d_%lld_%d_%lld", concreteFileLocation.dc_id, concreteFileLocation.volume_id, concreteFileLocation.local_id, concreteFileLocation.secret];
    }
    else if ([fileLocation isKindOfClass:[Secret23_FileLocation_fileLocation class]])
    {
        Secret23_FileLocation_fileLocation *concreteFileLocation = fileLocation;
        
        return [[NSString alloc] initWithFormat:@"%d_%lld_%d_%lld", concreteFileLocation.dcId.intValue, concreteFileLocation.volumeId.longLongValue, concreteFileLocation.localId.intValue, concreteFileLocation.secret.longLongValue];
    }
    else if ([fileLocation isKindOfClass:[Secret66_FileLocation_fileLocation class]])
    {
        Secret66_FileLocation_fileLocation *concreteFileLocation = fileLocation;
        
        return [[NSString alloc] initWithFormat:@"%d_%lld_%d_%lld", concreteFileLocation.dcId.intValue, concreteFileLocation.volumeId.longLongValue, concreteFileLocation.localId.intValue, concreteFileLocation.secret.longLongValue];
    }
    else if ([fileLocation isKindOfClass:[Secret66_FileLocation_fileLocation class]])
    {
        Secret66_FileLocation_fileLocation *concreteFileLocation = fileLocation;
        
        return [[NSString alloc] initWithFormat:@"%d_%lld_%d_%lld", concreteFileLocation.dcId.intValue, concreteFileLocation.volumeId.longLongValue, concreteFileLocation.localId.intValue, concreteFileLocation.secret.longLongValue];
    }
    else
    {
        TGLog(@"Warning: invalid fileLocation");
    }
    
    return nil;
}

bool extractFileUrlComponents(NSString *fileUrl, int *datacenterId, int64_t *volumeId, int *localId, int64_t *secret)
{
    if (fileUrl == nil || fileUrl.length == 0)
        return false;
    
    NSRange datacenterIdRange = NSMakeRange(NSNotFound, 0);
    NSRange volumeIdRange = NSMakeRange(NSNotFound, 0);
    NSRange localIdRange = NSMakeRange(NSNotFound, 0);
    NSRange secretRange = NSMakeRange(NSNotFound, 0);
    
    int length = (int)fileUrl.length;
    for (int i = 0; i <= length; i++)
    {
        if (i == length)
        {
            secretRange = NSMakeRange(localIdRange.location + localIdRange.length + 1, i - (localIdRange.location + localIdRange.length + 1));
            
            break;
        }
        
        unichar c = [fileUrl characterAtIndex:i];
        if (c == '_')
        {
            if (datacenterIdRange.location == NSNotFound)
                datacenterIdRange = NSMakeRange(0, i);
            else if (volumeIdRange.location == NSNotFound)
                volumeIdRange = NSMakeRange(datacenterIdRange.location + datacenterIdRange.length + 1, i - (datacenterIdRange.location + datacenterIdRange.length + 1));
            else if (localIdRange.location == NSNotFound)
                localIdRange = NSMakeRange(volumeIdRange.location + volumeIdRange.length + 1, i - (volumeIdRange.location + volumeIdRange.length + 1));
        }
    }
    
    if (datacenterIdRange.location == NSNotFound || volumeIdRange.location == NSNotFound || localIdRange.location == NSNotFound || secretRange.location == NSNotFound)
        return false;
    
    if (datacenterId != NULL)
        *datacenterId = [[fileUrl substringWithRange:datacenterIdRange] intValue];
    if (volumeId != NULL)
        *volumeId = [[fileUrl substringWithRange:volumeIdRange] longLongValue];
    if (localId != NULL)
        *localId = [[fileUrl substringWithRange:localIdRange] intValue];
    if (secret != NULL)
        *secret = [[fileUrl substringWithRange:secretRange] longLongValue];
    
    return true;
}

@implementation TGImageInfo (Telegraph)

- (id)initWithTelegraphSizesDescription:(NSArray *)sizesDesc
{
    return [self initWithTelegraphSizesDescription:sizesDesc cachedData:nil];
}

- (id)initWithTelegraphSizesDescription:(NSArray *)sizesDesc cachedData:(__autoreleasing NSData **)cachedData
{
    self = [super init];
    if (self != nil)
    {   
        for (TLPhotoSize *sizeDesc in sizesDesc)
        {
            if ([sizeDesc isKindOfClass:[TLPhotoSize$photoSize class]])
            {
                TLPhotoSize$photoSize *concreteSize = (TLPhotoSize$photoSize *)sizeDesc;
                NSString *urlLocation = extractFileUrl(concreteSize.location);
                
#ifdef DEBUG
                if ([concreteSize.type isEqualToString:@"s"])
                {
                    TGLog(@"***** Non-cached photo size received: %@", urlLocation);
                }
#endif
                
                [self addImageWithSize:CGSizeMake(concreteSize.w, concreteSize.h) url:urlLocation fileSize:concreteSize.size];
            }
            else if ([sizeDesc isKindOfClass:[TLPhotoSize$photoCachedSize class]])
            {
                TLPhotoSize$photoCachedSize *concreteSize = (TLPhotoSize$photoCachedSize *)sizeDesc;
                
                NSString *url = extractFileUrl(concreteSize.location);
                
                [self addImageWithSize:CGSizeMake(concreteSize.w, concreteSize.h) url:url fileSize:(int32_t)concreteSize.bytes.length];
                
                if (concreteSize.bytes.length != 0)
                {
                    NSData *imageData = concreteSize.bytes;
                    if (cachedData != NULL)
                        *cachedData = imageData;
                    else
                    {
                        if (url != nil)
                        {
                            [[TGRemoteImageView sharedCache] diskCacheContains:url orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                            {
                                if (!containsFirst)
                                {
                                    if (TGEnableBlur() && cpuCoreCount() > 1)
                                    {
                                        NSData *data = nil;
                                        TGScaleAndBlurImage(imageData, CGSizeZero, &data);
                                        if (data != nil)
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:url availability:TGCacheDisk];
                                        else
                                            [[TGRemoteImageView sharedCache] cacheImage:nil withData:imageData url:url availability:TGCacheDisk];
                                    }
                                    else
                                        [[TGRemoteImageView sharedCache] cacheImage:nil withData:imageData url:url availability:TGCacheDisk];
                                }
                            }];
                        }
                    }
                }
            }
        }
    }
    return self;
}

- (id)initWithSecret23SizesDescription:(NSArray *)sizesDesc cachedData:(__autoreleasing NSData **)cachedData
{
    self = [super init];
    if (self != nil)
    {
        for (id sizeDesc in sizesDesc)
        {
            if ([sizeDesc isKindOfClass:[Secret23_PhotoSize_photoSize class]])
            {
                Secret23_PhotoSize_photoSize *concreteSize = sizeDesc;
                NSString *urlLocation = extractFileUrl(concreteSize.location);
                
                [self addImageWithSize:CGSizeMake(concreteSize.w.intValue, concreteSize.h.intValue) url:urlLocation];
            }
            else if ([sizeDesc isKindOfClass:[Secret23_PhotoSize_photoCachedSize class]])
            {
                Secret23_PhotoSize_photoCachedSize *concreteSize = sizeDesc;
                
                NSString *url = extractFileUrl(concreteSize.location);
                
                [self addImageWithSize:CGSizeMake(concreteSize.w.intValue, concreteSize.h.intValue) url:url];
                
                if (concreteSize.bytes.length != 0)
                {
                    NSData *imageData = concreteSize.bytes;
                    if (cachedData != NULL)
                    *cachedData = imageData;
                    else
                    {
                        if (url != nil)
                        {
                            [[TGRemoteImageView sharedCache] diskCacheContains:url orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                             {
                                 if (!containsFirst)
                                 {
                                     if (TGEnableBlur() && cpuCoreCount() > 1)
                                     {
                                         NSData *data = nil;
                                         TGScaleAndBlurImage(imageData, CGSizeZero, &data);
                                         if (data != nil)
                                         [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:url availability:TGCacheDisk];
                                         else
                                         [[TGRemoteImageView sharedCache] cacheImage:nil withData:imageData url:url availability:TGCacheDisk];
                                     }
                                     else
                                     [[TGRemoteImageView sharedCache] cacheImage:nil withData:imageData url:url availability:TGCacheDisk];
                                 }
                             }];
                        }
                    }
                }
            }
        }
    }
    return self;
}

- (id)initWithSecret46SizesDescription:(NSArray *)sizesDesc cachedData:(__autoreleasing NSData **)cachedData {
    self = [super init];
    if (self != nil)
    {
        for (id sizeDesc in sizesDesc)
        {
            if ([sizeDesc isKindOfClass:[Secret46_PhotoSize_photoSize class]])
            {
                Secret46_PhotoSize_photoSize *concreteSize = sizeDesc;
                NSString *urlLocation = extractFileUrl(concreteSize.location);
                
                [self addImageWithSize:CGSizeMake(concreteSize.w.intValue, concreteSize.h.intValue) url:urlLocation];
            }
            else if ([sizeDesc isKindOfClass:[Secret46_PhotoSize_photoCachedSize class]])
            {
                Secret46_PhotoSize_photoCachedSize *concreteSize = sizeDesc;
                
                NSString *url = extractFileUrl(concreteSize.location);
                
                [self addImageWithSize:CGSizeMake(concreteSize.w.intValue, concreteSize.h.intValue) url:url];
                
                if (concreteSize.bytes.length != 0)
                {
                    NSData *imageData = concreteSize.bytes;
                    if (cachedData != NULL)
                        *cachedData = imageData;
                    else
                    {
                        if (url != nil)
                        {
                            [[TGRemoteImageView sharedCache] diskCacheContains:url orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                             {
                                 if (!containsFirst)
                                 {
                                     if (TGEnableBlur() && cpuCoreCount() > 1)
                                     {
                                         NSData *data = nil;
                                         TGScaleAndBlurImage(imageData, CGSizeZero, &data);
                                         if (data != nil)
                                             [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:url availability:TGCacheDisk];
                                         else
                                             [[TGRemoteImageView sharedCache] cacheImage:nil withData:imageData url:url availability:TGCacheDisk];
                                     }
                                     else
                                         [[TGRemoteImageView sharedCache] cacheImage:nil withData:imageData url:url availability:TGCacheDisk];
                                 }
                             }];
                        }
                    }
                }
            }
        }
    }
    return self;
}

- (id)initWithSecret66SizesDescription:(NSArray *)sizesDesc cachedData:(__autoreleasing NSData **)cachedData {
    self = [super init];
    if (self != nil)
    {
        for (id sizeDesc in sizesDesc)
        {
            if ([sizeDesc isKindOfClass:[Secret66_PhotoSize_photoSize class]])
            {
                Secret66_PhotoSize_photoSize *concreteSize = sizeDesc;
                NSString *urlLocation = extractFileUrl(concreteSize.location);
                
                [self addImageWithSize:CGSizeMake(concreteSize.w.intValue, concreteSize.h.intValue) url:urlLocation];
            }
            else if ([sizeDesc isKindOfClass:[Secret66_PhotoSize_photoCachedSize class]])
            {
                Secret66_PhotoSize_photoCachedSize *concreteSize = sizeDesc;
                
                NSString *url = extractFileUrl(concreteSize.location);
                
                [self addImageWithSize:CGSizeMake(concreteSize.w.intValue, concreteSize.h.intValue) url:url];
                
                if (concreteSize.bytes.length != 0)
                {
                    NSData *imageData = concreteSize.bytes;
                    if (cachedData != NULL)
                        *cachedData = imageData;
                    else
                    {
                        if (url != nil)
                        {
                            [[TGRemoteImageView sharedCache] diskCacheContains:url orUrl:nil completion:^(bool containsFirst, __unused bool containsSecond)
                             {
                                 if (!containsFirst)
                                 {
                                     if (TGEnableBlur() && cpuCoreCount() > 1)
                                     {
                                         NSData *data = nil;
                                         TGScaleAndBlurImage(imageData, CGSizeZero, &data);
                                         if (data != nil)
                                             [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:url availability:TGCacheDisk];
                                         else
                                             [[TGRemoteImageView sharedCache] cacheImage:nil withData:imageData url:url availability:TGCacheDisk];
                                     }
                                     else
                                         [[TGRemoteImageView sharedCache] cacheImage:nil withData:imageData url:url availability:TGCacheDisk];
                                 }
                             }];
                        }
                    }
                }
            }
        }
    }
    return self;
}

@end
