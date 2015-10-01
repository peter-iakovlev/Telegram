#import "TGSharedMediaGroup.h"

#import "TGSharedMediaImageItem.h"
#import "TGSharedMediaVideoItem.h"
#import "TGSharedMediaFileItem.h"
#import "TGSharedMediaLinkItem.h"

@implementation TGSharedMediaGroup

- (instancetype)initWithDate:(NSTimeInterval)date items:(NSArray *)items
{
    self = [super init];
    if (self != nil)
    {
        _date = date;
        _items = items;
        
        bool initializedContentType = false;
        TGSharedMediaGroupContentType contentType = TGSharedMediaGroupContentTypeUnknown;
        
        for (id<TGSharedMediaItem> item in items)
        {
            if ([item isKindOfClass:[TGSharedMediaImageItem class]])
            {
                if (!initializedContentType)
                {
                    initializedContentType = true;
                    contentType = TGSharedMediaGroupContentTypeImage;
                }
                else if (contentType != TGSharedMediaGroupContentTypeImage)
                {
                    contentType = TGSharedMediaGroupContentTypeUnknown;
                    break;
                }
            }
            else if ([item isKindOfClass:[TGSharedMediaVideoItem class]])
            {
                if (!initializedContentType)
                {
                    initializedContentType = true;
                    contentType = TGSharedMediaGroupContentTypeVideo;
                }
                else if (contentType != TGSharedMediaGroupContentTypeVideo)
                {
                    contentType = TGSharedMediaGroupContentTypeUnknown;
                    break;
                }
            }
            else if ([item isKindOfClass:[TGSharedMediaFileItem class]])
            {
                if (!initializedContentType)
                {
                    initializedContentType = true;
                    contentType = TGSharedMediaGroupContentTypeFile;
                }
                else if (contentType != TGSharedMediaGroupContentTypeFile)
                {
                    contentType = TGSharedMediaGroupContentTypeUnknown;
                    break;
                }
            }
            else if ([item isKindOfClass:[TGSharedMediaLinkItem class]])
            {
                if (!initializedContentType)
                {
                    initializedContentType = true;
                    contentType = TGSharedMediaGroupContentTypeLink;
                }
                else if (contentType != TGSharedMediaGroupContentTypeLink)
                {
                    contentType = TGSharedMediaGroupContentTypeUnknown;
                    break;
                }
            }
            else
            {
                contentType = TGSharedMediaGroupContentTypeUnknown;
                break;
            }
        }
        
        _contentType = contentType;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TGSharedMediaGroup class]])
    {
        return _contentType == ((TGSharedMediaGroup *)object)->_contentType && [_items isEqualToArray:((TGSharedMediaGroup *)object)->_items];
    }
    
    return false;
}

@end
