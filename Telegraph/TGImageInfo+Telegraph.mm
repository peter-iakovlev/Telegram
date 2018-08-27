#import "TGImageInfo+Telegraph.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGSchema.h"

#import <LegacyComponents/TGCache.h>
#import <LegacyComponents/TGRemoteImageView.h>

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
    else if ([fileLocation isKindOfClass:[Secret73_FileLocation_fileLocation class]])
    {
        Secret73_FileLocation_fileLocation *concreteFileLocation = fileLocation;
        
        return [[NSString alloc] initWithFormat:@"%d_%lld_%d_%lld", concreteFileLocation.dcId.intValue, concreteFileLocation.volumeId.longLongValue, concreteFileLocation.localId.intValue, concreteFileLocation.secret.longLongValue];
    }
    else
    {
        TGLog(@"Warning: invalid fileLocation");
    }
    
    return nil;
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

- (id)initWithSecret73SizesDescription:(NSArray *)sizesDesc cachedData:(__autoreleasing NSData **)cachedData {
    self = [super init];
    if (self != nil)
    {
        for (id sizeDesc in sizesDesc)
        {
            if ([sizeDesc isKindOfClass:[Secret73_PhotoSize_photoSize class]])
            {
                Secret73_PhotoSize_photoSize *concreteSize = sizeDesc;
                NSString *urlLocation = extractFileUrl(concreteSize.location);
                
                [self addImageWithSize:CGSizeMake(concreteSize.w.intValue, concreteSize.h.intValue) url:urlLocation];
            }
            else if ([sizeDesc isKindOfClass:[Secret73_PhotoSize_photoCachedSize class]])
            {
                Secret73_PhotoSize_photoCachedSize *concreteSize = sizeDesc;
                
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
