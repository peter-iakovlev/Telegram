#import "TGWebPageMediaAttachment.h"

#import "NSInputStream+TL.h"

@implementation TGWebPageMediaAttachment

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGWebPageMediaAttachmentType;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGWebPageMediaAttachmentType;
        
        _webPageId = [aDecoder decodeInt64ForKey:@"webPageId"];
        _pendingDate = [aDecoder decodeInt32ForKey:@"pendingDate"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        _displayUrl = [aDecoder decodeObjectForKey:@"displayUrl"];
        _pageType = [aDecoder decodeObjectForKey:@"pageType"];
        _siteName = [aDecoder decodeObjectForKey:@"siteName"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _pageDescription = [aDecoder decodeObjectForKey:@"pageDescription"];
        _photo = [aDecoder decodeObjectForKey:@"photo"];
        _embedUrl = [aDecoder decodeObjectForKey:@"embedUrl"];
        _embedType = [aDecoder decodeObjectForKey:@"embedType"];
        _embedSize = [[aDecoder decodeObjectForKey:@"embedSize"] CGSizeValue];
        _duration = [aDecoder decodeObjectForKey:@"duration"];
        _author = [aDecoder decodeObjectForKey:@"author"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:_webPageId forKey:@"webPageId"];
    [aCoder encodeInt32:_pendingDate forKey:@"pendingDate"];
    if (_url != nil)
        [aCoder encodeObject:_url forKey:@"url"];
    if (_displayUrl != nil)
        [aCoder encodeObject:_displayUrl forKey:@"displayUrl"];
    if (_pageType != nil)
        [aCoder encodeObject:_pageType forKey:@"pageType"];
    if (_siteName != nil)
        [aCoder encodeObject:_siteName forKey:@"siteName"];
    if (_title != nil)
        [aCoder encodeObject:_title forKey:@"title"];
    if (_pageDescription != nil)
        [aCoder encodeObject:_pageDescription forKey:@"pageDescription"];
    if (_photo != nil)
        [aCoder encodeObject:_photo forKey:@"photo"];
    if (_embedUrl != nil)
        [aCoder encodeObject:_embedUrl forKey:@"embedUrl"];
    if (_embedType != nil)
        [aCoder encodeObject:_embedType forKey:@"embedType"];
    [aCoder encodeObject:[NSValue valueWithCGSize:_embedSize] forKey:@"embedSize"];
    if (_duration != nil)
        [aCoder encodeObject:_duration forKey:@"duration"];
    if (_author != nil)
        [aCoder encodeObject:_author forKey:@"author"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebPageMediaAttachment class]] &&
        ((TGWebPageMediaAttachment *)object)->_webPageId == _webPageId &&
        ((TGWebPageMediaAttachment *)object)->_pendingDate == _pendingDate &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_url, _url) &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_displayUrl, _displayUrl) &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_pageType, _pageType) &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_siteName, _siteName) &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_title, _title) &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_pageDescription, _pageDescription) &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_embedUrl, _embedUrl) &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_embedType, _embedType) &&
        ((TGWebPageMediaAttachment *)object)->_duration == _duration &&
        TGStringCompare(((TGWebPageMediaAttachment *)object)->_author, _author);
}

- (void)serialize:(NSMutableData *)data
{
    NSData *serializedData = [NSKeyedArchiver archivedDataWithRootObject:self];
    int32_t length = (int32_t)serializedData.length;
    [data appendBytes:&length length:4];
    [data appendData:serializedData];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int32_t length = [is readInt32];
    NSData *data = [is readData:length];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
