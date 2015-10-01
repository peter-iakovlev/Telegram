#import "TGBridgeImageInfo.h"

NSString *const TGBridgeImageSizeInfoUrlKey = @"url";
NSString *const TGBridgeImageSizeInfoDimensionsKey = @"dimensions";
NSString *const TGBridgeImageSizeInfoFileSizeKey = @"fileSize";

@implementation TGBridgeImageSizeInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _url = [aDecoder decodeObjectForKey:TGBridgeImageSizeInfoUrlKey];
        _dimensions = [aDecoder decodeCGSizeForKey:TGBridgeImageSizeInfoDimensionsKey];
        _fileSize = [aDecoder decodeInt32ForKey:TGBridgeImageSizeInfoFileSizeKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:TGBridgeImageSizeInfoUrlKey];
    [aCoder encodeCGSize:self.dimensions forKey:TGBridgeImageSizeInfoDimensionsKey];
    [aCoder encodeInt32:self.fileSize forKey:TGBridgeImageSizeInfoFileSizeKey];
}

@end

NSString *const TGBridgeImageInfoEntriesKey = @"entries";

@implementation TGBridgeImageInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _entries = [aDecoder decodeObjectForKey:TGBridgeImageInfoEntriesKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.entries forKey:TGBridgeImageInfoEntriesKey];
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
    TGBridgeImageSizeInfo *closestEntry = nil;
    CGFloat closestDeltaSquared = FLT_MAX;
    
    for (TGBridgeImageSizeInfo *entry in self.entries)
    {
        CGFloat deltaWidth = ABS(size.width - entry.dimensions.width);
        CGFloat deltaHeight = ABS(size.height - entry.dimensions.height);
        
        CGFloat currentDeltaSquared = deltaWidth * deltaWidth + deltaHeight * deltaHeight;
        
        if (closestEntry == nil || currentDeltaSquared < closestDeltaSquared || (pickLargest && currentDeltaSquared <= closestDeltaSquared + FLT_EPSILON))
        {
            closestEntry = entry;
            closestDeltaSquared = currentDeltaSquared;
        }
    }
    
    if (resultingSize != NULL)
        *resultingSize = closestEntry.dimensions;
    
    if (resultingFileSize != NULL)
        *resultingFileSize = closestEntry.fileSize;
    
    return closestEntry.url;
}

- (NSString *)imageUrlForSizeLargerThanSize:(CGSize)size actualSize:(CGSize *)actualSize
{
    TGBridgeImageSizeInfo *largestEntry = nil;
    
    for (TGBridgeImageSizeInfo *entry in self.entries)
    {
        if (entry.dimensions.width > size.width && (largestEntry == nil || entry.dimensions.width < largestEntry.dimensions.width))
        {
            largestEntry = entry;
            break;
        }
    }
    
    NSString *largestUrl = largestEntry.url;
    
    if (largestUrl == nil)
        largestUrl = [self closestImageUrlWithSize:size resultingSize:actualSize pickLargest:true];
    else if (actualSize)
        *actualSize = largestEntry.dimensions;
    
    return largestUrl;
}

- (NSString *)imageUrlForLargestSize:(CGSize *)actualSize
{
    TGBridgeImageSizeInfo *largestEntry = nil;
    
    for (TGBridgeImageSizeInfo *entry in self.entries)
    {
        if (entry.dimensions.width > largestEntry.dimensions.width)
            largestEntry = entry;
    }
    
    if (actualSize != NULL)
        *actualSize = largestEntry.dimensions;
    
    return largestEntry.url;
}

@end
