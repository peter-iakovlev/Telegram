#import "TGFileLocation.h"

@implementation TGFileLocation

- (instancetype)initWithDatacenterId:(NSInteger)datacenterId volumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret
{
    self = [super init];
    if (self != nil)
    {
        _datacenterId = datacenterId;
        _volumeId = volumeId;
        _localId = localId;
        _secret = secret;
    }
    return self;
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

- (instancetype)initWithFileUrl:(NSString *)url
{
    int32_t datacenterId;
    int64_t volumeId;
    int32_t localId;
    int64_t secret;
    
    if (extractFileUrlComponents(url, &datacenterId, &volumeId, &localId, &secret))
        return [self initWithDatacenterId:datacenterId volumeId:volumeId localId:localId secret:secret];
    else
        return nil;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(TGFileLocation datacenterId: %" PRId32 ", %" PRId64 ", %" PRId32 ", %" PRId64, (int32_t)_datacenterId, _volumeId, _localId, _secret];
}

@end
