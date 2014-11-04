#import "TGImageInfo.h"

#import <vector>

struct TGImageSizeRecord
{
    CGSize size;
    NSString *url;
    int fileSize;
    
    TGImageSizeRecord(CGSize size_, NSString *url_, int fileSize_) :
        size(size_), fileSize(fileSize_)
    {
        url = url_;
    }
    
    TGImageSizeRecord(const TGImageSizeRecord &other)
    {
        url = other.url;
        size = other.size;
        fileSize = other.fileSize;
    }
    
    TGImageSizeRecord & operator= (const TGImageSizeRecord &other)
    {
        if (this != &other)
        {
            url = other.url;
            size = other.size;
            fileSize = other.fileSize;
        }
        
        return *this;
    }

    ~TGImageSizeRecord()
    {
        url = nil;
    }
};

@interface TGImageInfo ()
{
    std::vector<TGImageSizeRecord> sizes;
}

@end

@implementation TGImageInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        for (NSDictionary *sizeDict in [aDecoder decodeObjectForKey:@"sizes"])
        {
            [self addImageWithSize:CGSizeMake([sizeDict[@"width"] floatValue], [sizeDict[@"height"] floatValue]) url:sizeDict[@"url"] fileSize:[sizeDict[@"fileSize"] intValue]];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (auto it : sizes)
    {
        [array addObject:@{@"width": @(it.size.width), @"height": @(it.size.height), @"url": it.url == nil ? @"" : it.url, @"fileSize": @(it.fileSize)}];
    }
    [aCoder encodeObject:array forKey:@"sizes"];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[TGImageInfo class]])
        return false;
    
    TGImageInfo *other = (TGImageInfo *)object;
    
    if (sizes.size() != other->sizes.size())
        return false;
    
    for (int i = 0; i < sizes.size(); i++)
    {
        if (!CGSizeEqualToSize(sizes[i].size, other->sizes[i].size))
            return false;
        
        if (![sizes[i].url isEqualToString:other->sizes[i].url])
            return false;
    }
    
    return true;
}

- (void)addImageWithSize:(CGSize)size url:(NSString *)url
{
    sizes.push_back(TGImageSizeRecord(size, url, 0));
}

- (void)addImageWithSize:(CGSize)size url:(NSString *)url fileSize:(int)fileSize
{
    sizes.push_back(TGImageSizeRecord(size, url, fileSize));
}

- (NSString *)closestImageUrlWithWidth:(int)width resultingSize:(CGSize *)resultingSize
{
    CGSize closestSize = CGSizeZero;
    NSString *closestUrl = nil;
    for (std::vector<TGImageSizeRecord>::iterator it = sizes.begin(); it != sizes.end(); it++)
    {
        if (closestUrl == nil)
        {
            closestUrl = it->url;
            closestSize = it->size;
        }
        else
        {
            if (ABS(width - it->size.width) < ABS(width - closestSize.width))
            {
                closestUrl = it->url;
                closestSize = it->size;
            }
        }
    }
    
    if (resultingSize != NULL)
        *resultingSize = closestSize;
    
    return closestUrl;
}

- (NSString *)closestImageUrlWithHeight:(int)height resultingSize:(CGSize *)resultingSize
{
    CGSize closestSize = CGSizeZero;
    NSString *closestUrl = nil;
    for (std::vector<TGImageSizeRecord>::iterator it = sizes.begin(); it != sizes.end(); it++)
    {
        if (closestUrl == nil)
        {
            closestUrl = it->url;
            closestSize = it->size;
        }
        else
        {
            if (ABS(height - it->size.height) < ABS(height - closestSize.height))
            {
                closestUrl = it->url;
                closestSize = it->size;
            }
        }
    }
    
    if (resultingSize != NULL)
        *resultingSize = closestSize;
    
    return closestUrl;
}

- (NSString *)closestImageUrlWithSize:(CGSize)size resultingSize:(CGSize *)resultingSize
{
    return [self closestImageUrlWithSize:size resultingSize:resultingSize pickLargest:false];
}

- (NSString *)closestImageUrlWithSize:(CGSize)size resultingSize:(CGSize *)resultingSize resultingFileSize:(int *)resultingFileSize
{
    return [self closestImageUrlWithSize:size resultingSize:resultingSize resultingFileSize:resultingFileSize pickLargest:false];
}

- (NSString *)closestImageUrlWithSize:(CGSize)size resultingSize:(CGSize *)resultingSize pickLargest:(bool)pickLargest
{
    return [self closestImageUrlWithSize:size resultingSize:resultingSize resultingFileSize:NULL pickLargest:pickLargest];
}

- (NSString *)closestImageUrlWithSize:(CGSize)size resultingSize:(CGSize *)resultingSize resultingFileSize:(int *)resultingFileSize pickLargest:(bool)pickLargest
{
    CGSize closestSize = CGSizeZero;
    int closestFileSize = 0;
    float closestDeltaSquared = FLT_MAX;
    NSString *closestUrl = nil;
    for (std::vector<TGImageSizeRecord>::iterator it = sizes.begin(); it != sizes.end(); it++)
    {
        float deltaWidth = ABS(size.width - it->size.width);
        float deltaHeight = ABS(size.height - it->size.height);
        
        float currentDeltaSquared = deltaWidth * deltaWidth + deltaHeight * deltaHeight;
        
        if (closestUrl == nil || currentDeltaSquared < closestDeltaSquared || (pickLargest && currentDeltaSquared <= closestDeltaSquared + FLT_EPSILON))
        {
            closestUrl = it->url;
            closestSize = it->size;
            closestFileSize = it->fileSize;
            closestDeltaSquared = deltaWidth * deltaWidth + deltaHeight * deltaHeight;
        }
    }
    
    if (resultingSize != NULL)
        *resultingSize = closestSize;
    
    if (resultingFileSize != NULL)
        *resultingFileSize = closestFileSize;
    
    return closestUrl;
}

- (NSString *)imageUrlWithExactSize:(CGSize)size
{
    for (std::vector<TGImageSizeRecord>::iterator it = sizes.begin(); it != sizes.end(); it++)
    {
        float deltaWidth = ABS(size.width - it->size.width);
        float deltaHeight = ABS(size.height - it->size.height);
        
        if (deltaWidth < 1 + FLT_EPSILON && deltaHeight < 1 + FLT_EPSILON)
        {
            return it->url;
        }
    }
    
    return nil;
}

- (NSString *)imageUrlForLargestSize:(CGSize *)actualSize
{
    NSString *largestUrl = nil;
    CGSize largestSize = CGSizeZero;
    
    for (auto it = sizes.begin(); it != sizes.end(); it++)
    {
        if (it->size.width > largestSize.width)
        {
            largestUrl = it->url;
            largestSize = it->size;
        }
    }
    
    if (actualSize != NULL)
        *actualSize = largestSize;
    
    return largestUrl;
}

- (bool)containsSizeWithUrl:(NSString *)url
{
    if (url == nil)
        return false;
    
    for (std::vector<TGImageSizeRecord>::iterator it = sizes.begin(); it != sizes.end(); it++)
    {
        if ([url isEqualToString:it->url])
            return true;
    }
    
    return false;
}

- (NSDictionary *)allSizes
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (std::vector<TGImageSizeRecord>::iterator it = sizes.begin(); it != sizes.end(); it++)
    {
        [dict setObject:[NSValue valueWithCGSize:it->size] forKey:it->url];
    }
    
    return dict;
}

- (bool)empty
{
    return sizes.empty();
}

- (void)serialize:(NSMutableData *)data
{
    int writtenCount = sizes.size();
    writtenCount |= (1 << 31);
    [data appendBytes:&writtenCount length:4];
    
    uint16_t version = 1;
    [data appendBytes:&version length:2];
    
    for (std::vector<TGImageSizeRecord>::iterator it = sizes.begin(); it != sizes.end(); it++)
    {
        NSData *urlData = [it->url dataUsingEncoding:NSUTF8StringEncoding];
        int length = urlData.length;
        [data appendBytes:&length length:4];
        [data appendData:urlData];
        
        [data appendBytes:&it->size.width length:4];
        [data appendBytes:&it->size.height length:4];
        [data appendBytes:&it->fileSize length:4];
    }
}

+ (TGImageInfo *)deserialize:(NSInputStream *)is
{
    TGImageInfo *info = [[TGImageInfo alloc] init];
    
    uint16_t version = 0;
    
    int count = 0;
    [is read:(uint8_t *)&count maxLength:4];
    
    if (count & (1 << 31))
    {
        count &= ~(1 << 31);
        [is read:(uint8_t *)&version maxLength:2];
    }
    
    for (int i = 0; i < count; i++)
    {
        int length = 0;
        [is read:(uint8_t *)&length maxLength:4];
        uint8_t *urlBytes = (uint8_t *)malloc(length);
        [is read:urlBytes maxLength:length];
        NSString *url = [[NSString alloc] initWithBytesNoCopy:urlBytes length:length encoding:NSUTF8StringEncoding freeWhenDone:true];
        
        CGSize size = CGSizeZero;
        [is read:(uint8_t *)&size.width maxLength:4];
        [is read:(uint8_t *)&size.height maxLength:4];
        
        int fileSize = 0;
        if (version >= 1)
            [is read:(uint8_t *)&fileSize maxLength:4];
        
        [info addImageWithSize:size url:url fileSize:fileSize];
    }
    
    return info;
}

@end
