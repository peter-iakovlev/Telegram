#import "TGVideoMediaAttachment.h"

#import "TGMessage.h"

@interface TGVideoMediaAttachment ()
{
    NSArray *_textCheckingResults;
}
@end

@implementation TGVideoMediaAttachment

@synthesize videoId = _videoId;
@synthesize accessHash = _accessHash;

@synthesize localVideoId = _localVideoId;

@synthesize duration = _duration;
@synthesize dimensions = _dimensions;

@synthesize videoInfo = _videoInfo;
@synthesize thumbnailInfo = _thumbnailInfo;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGVideoMediaAttachmentType;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
    
    videoAttachment.videoId = _videoId;
    videoAttachment.accessHash = _accessHash;
    videoAttachment.localVideoId = _localVideoId;
    videoAttachment.duration = _duration;
    videoAttachment.dimensions = _dimensions;
    videoAttachment.videoInfo = _videoInfo;
    videoAttachment.thumbnailInfo = _thumbnailInfo;
    videoAttachment.caption = _caption;
    
    return videoAttachment;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[TGVideoMediaAttachment class]])
        return false;
    
    TGVideoMediaAttachment *other = object;
    
    if (_videoId != other.videoId || _accessHash != other.accessHash || _localVideoId != other.localVideoId || _duration != other.duration || !CGSizeEqualToSize(_dimensions, other.dimensions))
        return false;
    
    if (!TGObjectCompare(_videoInfo, other.videoInfo))
        return false;
    
    if (!TGObjectCompare(_thumbnailInfo, other.thumbnailInfo))
        return false;
    
    if (!TGObjectCompare(_caption, other.caption))
        return false;
    
    return true;
}

- (void)serialize:(NSMutableData *)data
{
    int32_t modernTag = 0x7abacaf1;
    [data appendBytes:&modernTag length:4];
    
    uint8_t version = 2;
    [data appendBytes:&version length:1];
    
    int dataLengthPtr = (int)data.length;
    int zero = 0;
    [data appendBytes:&zero length:4];
    
    [data appendBytes:&_videoId length:8];
    [data appendBytes:&_accessHash length:8];
    
    [data appendBytes:&_localVideoId length:8];
    
    uint8_t hasVideoInfo = _videoInfo != nil ? 1 : 0;
    [data appendBytes:&hasVideoInfo length:1];
    if (hasVideoInfo != 0)
        [_videoInfo serialize:data];
    
    uint8_t hasThumbnailInfo = _thumbnailInfo != nil ? 1 : 0;
    [data appendBytes:&hasThumbnailInfo length:1];
    if (hasThumbnailInfo != 0)
        [_thumbnailInfo serialize:data];
    
    [data appendBytes:&_duration length:4];
    
    int dimension = (int)_dimensions.width;
    [data appendBytes:&dimension length:4];
    dimension = (int)_dimensions.height;
    [data appendBytes:&dimension length:4];
    
    NSData *captionData = [_caption dataUsingEncoding:NSUTF8StringEncoding];
    int32_t captionLength = (int32_t)captionData.length;
    [data appendBytes:&captionLength length:4];
    if (captionLength != 0)
        [data appendData:captionData];
    
    int dataLength = (int)(data.length - dataLengthPtr - 4);
    [data replaceBytesInRange:NSMakeRange(dataLengthPtr, 4) withBytes:&dataLength];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int32_t dataLength = 0;
    [is read:(uint8_t *)&dataLength maxLength:4];
    
    uint8_t version = 1;
    if (dataLength == 0x7abacaf1)
    {
        [is read:(uint8_t *)&version maxLength:1];
        [is read:(uint8_t *)&dataLength maxLength:4];
    }
    
    TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
    
    int64_t videoId = 0;
    [is read:(uint8_t *)&videoId maxLength:8];
    videoAttachment.videoId = videoId;
    
    int64_t accessHash = 0;
    [is read:(uint8_t *)&accessHash maxLength:8];
    videoAttachment.accessHash = accessHash;
    
    int64_t localVideoId = 0;
    [is read:(uint8_t *)&localVideoId maxLength:8];
    videoAttachment.localVideoId = localVideoId;
    
    uint8_t hasVideoInfo = 0;
    [is read:&hasVideoInfo maxLength:1];
    
    if (hasVideoInfo != 0)
        videoAttachment.videoInfo = [TGVideoInfo deserialize:is];
    
    uint8_t hasThumbnailInfo = 0;
    [is read:&hasThumbnailInfo maxLength:1];
    
    if (hasThumbnailInfo != 0)
        videoAttachment.thumbnailInfo = [TGImageInfo deserialize:is];
    
    int duration = 0;
    [is read:(uint8_t *)&duration maxLength:4];
    videoAttachment.duration = duration;
    
    CGSize dimensions = CGSizeZero;
    int dimension = 0;
    [is read:(uint8_t *)&dimension maxLength:4];
    dimensions.width = dimension;
    dimension = 0;
    [is read:(uint8_t *)&dimension maxLength:4];
    dimensions.height = dimension;
    videoAttachment.dimensions = dimensions;
    
    if (version >= 2)
    {
        int32_t captionLength = 0;
        [is read:(uint8_t *)&captionLength maxLength:4];
        if (captionLength != 0)
        {
            uint8_t *captionBytes = malloc(captionLength);
            [is read:captionBytes maxLength:captionLength];
            videoAttachment.caption = [[NSString alloc] initWithBytesNoCopy:captionBytes length:captionLength encoding:NSUTF8StringEncoding freeWhenDone:true];
        }
    }
    
    return videoAttachment;
}

- (NSArray *)textCheckingResults
{
    if (_caption.length < 2)
        _textCheckingResults = [NSArray array];
    
    if (_textCheckingResults == nil)
    {
        NSArray *textCheckingResults = [TGMessage textCheckingResultsForText:_caption highlightMentionsAndTags:true highlightCommands:true];
        _textCheckingResults = textCheckingResults ?: [NSArray array];
    }
    
    return _textCheckingResults;
}

@end
