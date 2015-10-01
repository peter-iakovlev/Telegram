#import "TGGoogleDriveItem.h"

#import "TGImageUtils.h"

#import "GDGoogleDriveMetadata.h"

@implementation TGGoogleDriveItem

+ (instancetype)googleDriveItemWithMetadata:(GDGoogleDriveMetadata *)metadata
{
    TGGoogleDriveItem *item = [[TGGoogleDriveItem alloc] init];
    
    item->_fileId = metadata.md5Checksum;
    item->_fileUrl = [NSURL URLWithString:metadata.downloadURLString];
    item->_fileName = metadata.title;
    item->_fileSize = metadata.fileSize;
    item->_mimeType = metadata.mimeType;

    CGSize imageSize = metadata.imageSize;
    if (!CGSizeEqualToSize(imageSize, CGSizeZero))
        item->_imageSize = imageSize;
    
    if (metadata.thumbnailURLString != nil && ![item->_fileName hasSuffix:@".webp"])
    {
        if (!CGSizeEqualToSize(imageSize, CGSizeZero))
        {
            item->_previewUrl = [NSURL URLWithString:metadata.thumbnailURLString];
            item->_previewSize = TGFitSize(imageSize, CGSizeMake(220, 220));
        }
    }
    
    if (item.fileUrl == nil)
        return nil;
    
    return item;
}

@end
