#import "TGDropboxItem.h"

#import "TGStringUtils.h"

@implementation TGDropboxItem

+ (instancetype)dropboxItemWithDictionary:(NSDictionary *)dictionary
{
    TGDropboxItem *item = [[TGDropboxItem alloc] init];
    
    item->_fileId = TGStringMD5(dictionary[@"link"]);
    item->_fileUrl = [NSURL URLWithString:dictionary[@"link"]];
    item->_fileName = dictionary[@"name"];
    item->_fileSize = [dictionary[@"bytes"] unsignedIntegerValue];
    
    if ([dictionary[@"thumbnails"] isKindOfClass:[NSDictionary class]])
    {
        NSString *previewUrl = dictionary[@"thumbnails"][@"200x200"];
        if (previewUrl != nil)
        {
            item->_previewUrl = [NSURL URLWithString:previewUrl];
            item->_previewSize = CGSizeMake(200, 200);
        }
        else
        {
            previewUrl = dictionary[@"thumbnails"][@"64x64"];
            if (previewUrl != nil)
            {
                item->_previewUrl = [NSURL URLWithString:previewUrl];
                item->_previewSize = CGSizeMake(64, 64);
            }
        }
    }
    
    if (item.fileUrl == nil)
        return nil;
    
    return item;
}

@end
