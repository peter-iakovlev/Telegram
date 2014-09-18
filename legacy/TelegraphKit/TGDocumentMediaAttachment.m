/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDocumentMediaAttachment.h"

@implementation TGDocumentMediaAttachment

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGDocumentMediaAttachmentType;
    }
    return self;
}

- (void)serialize:(NSMutableData *)data
{
    int dataLengthPtr = data.length;
    int zero = 0;
    [data appendBytes:&zero length:4];
    
    uint8_t version = 3;
    [data appendBytes:&version length:sizeof(version)];
    
    [data appendBytes:&_localDocumentId length:sizeof(_localDocumentId)];
    
    [data appendBytes:&_documentId length:sizeof(_documentId)];
    [data appendBytes:&_accessHash length:sizeof(_accessHash)];
    [data appendBytes:&_datacenterId length:sizeof(_datacenterId)];
    [data appendBytes:&_userId length:sizeof(_userId)];
    [data appendBytes:&_date length:sizeof(_date)];
    
    NSData *filenameData = [_fileName dataUsingEncoding:NSUTF8StringEncoding];
    int filenameLength = filenameData.length;
    [data appendBytes:&filenameLength length:sizeof(filenameLength)];
    [data appendData:filenameData];
    
    NSData *mimeData = [_mimeType dataUsingEncoding:NSUTF8StringEncoding];
    int mimeLength = mimeData.length;
    [data appendBytes:&mimeLength length:sizeof(mimeLength)];
    [data appendData:mimeData];
    
    [data appendBytes:&_size length:sizeof(_size)];
    
    uint8_t thumbnailExists = _thumbnailInfo != nil;
    [data appendBytes:&thumbnailExists length:sizeof(thumbnailExists)];
    [_thumbnailInfo serialize:data];
    
    NSData *uriData = [_documentUri dataUsingEncoding:NSUTF8StringEncoding];
    int uriLength = uriData.length;
    [data appendBytes:&uriLength length:sizeof(uriLength)];
    if (uriData != nil)
        [data appendData:uriData];
    
    int dataLength = data.length - dataLengthPtr - 4;
    [data replaceBytesInRange:NSMakeRange(dataLengthPtr, 4) withBytes:&dataLength];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int dataLength = 0;
    [is read:(uint8_t *)&dataLength maxLength:4];
    
    uint8_t version = 0;
    [is read:&version maxLength:sizeof(version)];
    if (version != 1 && version != 2 && version != 3)
    {
        TGLog(@"***** Document serialized version mismatch");
        return nil;
    }
    
    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
    
    if (version >= 2)
        [is read:(uint8_t *)&documentAttachment->_localDocumentId maxLength:sizeof(documentAttachment->_localDocumentId)];
    
    [is read:(uint8_t *)&documentAttachment->_documentId maxLength:sizeof(documentAttachment->_documentId)];
    [is read:(uint8_t *)&documentAttachment->_accessHash maxLength:sizeof(documentAttachment->_accessHash)];
    [is read:(uint8_t *)&documentAttachment->_datacenterId maxLength:sizeof(documentAttachment->_datacenterId)];
    [is read:(uint8_t *)&documentAttachment->_userId maxLength:sizeof(documentAttachment->_userId)];
    [is read:(uint8_t *)&documentAttachment->_date maxLength:sizeof(documentAttachment->_date)];
    
    int filenameLength = 0;
    [is read:(uint8_t *)&filenameLength maxLength:sizeof(filenameLength)];
    if (filenameLength != 0)
    {
        uint8_t *filenameBytes = malloc(filenameLength);
        [is read:filenameBytes maxLength:filenameLength];
        documentAttachment.fileName = [[NSString alloc] initWithBytesNoCopy:filenameBytes length:filenameLength encoding:NSUTF8StringEncoding freeWhenDone:true];
    }

    int mimeLength = 0;
    [is read:(uint8_t *)&mimeLength maxLength:sizeof(mimeLength)];
    if (mimeLength != 0)
    {
        uint8_t *mimeBytes = malloc(mimeLength);
        [is read:mimeBytes maxLength:mimeLength];
        documentAttachment.mimeType = [[NSString alloc] initWithBytesNoCopy:mimeBytes length:mimeLength encoding:NSUTF8StringEncoding freeWhenDone:true];
    }
    
    [is read:(uint8_t *)&documentAttachment->_size maxLength:sizeof(documentAttachment->_size)];
    
    uint8_t thumbnailExists = 0;
    [is read:&thumbnailExists maxLength:sizeof(thumbnailExists)];
    if (thumbnailExists)
    {
        documentAttachment.thumbnailInfo = [TGImageInfo deserialize:is];
    }
    
    if (version >= 3)
    {
        int uriLength = 0;
        [is read:(uint8_t *)&uriLength maxLength:sizeof(uriLength)];
        if (uriLength > 0)
        {
            uint8_t *uriBytes = malloc(uriLength);
            [is read:uriBytes maxLength:uriLength];
            documentAttachment.documentUri = [[NSString alloc] initWithBytesNoCopy:uriBytes length:uriLength encoding:NSUTF8StringEncoding freeWhenDone:true];
        }
    }
    
    return documentAttachment;
}

- (NSString *)safeFileName
{
    return [TGDocumentMediaAttachment safeFileNameForFileName:_fileName];
}

+ (NSString *)safeFileNameForFileName:(NSString *)fileName
{
    if (fileName.length == 0)
        return @"file";
    
    return [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

@end
