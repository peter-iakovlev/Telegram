/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDocumentMediaAttachment+Telegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGAppDelegate.h"

@implementation TGDocumentMediaAttachment (Telegraph)

- (instancetype)initWithTelegraphDocumentDesc:(TLDocument *)desc
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGDocumentMediaAttachmentType;
        
        self.documentId = desc.n_id;
        
        if ([desc isKindOfClass:[TLDocument$document class]])
        {
            TLDocument$document *concreteDocument = (TLDocument$document *)desc;
            
            self.accessHash = concreteDocument.access_hash;
            self.datacenterId = concreteDocument.dc_id;
            self.date = concreteDocument.date;
            
            NSMutableArray *attributes = [[NSMutableArray alloc] init];
            for (id attribute in concreteDocument.attributes)
            {
                if ([attribute isKindOfClass:[TLDocumentAttribute$documentAttributeFilename class]])
                {
                    TLDocumentAttribute$documentAttributeFilename *concreteAttribute = attribute;
                    [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:concreteAttribute.file_name]];
                }
                else if ([attribute isKindOfClass:[TLDocumentAttribute$documentAttributeAnimated class]])
                {
                    [attributes addObject:[[TGDocumentAttributeAnimated alloc] init]];
                }
                else if ([attribute isKindOfClass:[TLDocumentAttribute$documentAttributeImageSize class]])
                {
                    TLDocumentAttribute$documentAttributeImageSize *concreteAttribute = attribute;
                    [attributes addObject:[[TGDocumentAttributeImageSize alloc] initWithSize:CGSizeMake(concreteAttribute.w, concreteAttribute.h)]];
                }
                else if ([attribute isKindOfClass:[TLDocumentAttribute$documentAttributeSticker class]])
                {
                    TLDocumentAttribute$documentAttributeSticker *concreteAttribute = (TLDocumentAttribute$documentAttributeSticker *)attribute;
                    id<TGStickerPackReference> packReference = nil;
                    if ([concreteAttribute.stickerset isKindOfClass:[TLInputStickerSet$inputStickerSetID class]])
                    {
                        TLInputStickerSet$inputStickerSetID *concreteStickerset = (TLInputStickerSet$inputStickerSetID *)concreteAttribute.stickerset;
                        packReference = [[TGStickerPackIdReference alloc] initWithPackId:concreteStickerset.n_id packAccessHash:concreteStickerset.access_hash shortName:nil];
                    }
                    else if ([concreteAttribute.stickerset isKindOfClass:[TLInputStickerSet$inputStickerSetShortName class]])
                    {
                        TLInputStickerSet$inputStickerSetShortName *concreteStickerset = (TLInputStickerSet$inputStickerSetShortName *)concreteAttribute.stickerset;
                        packReference = [[TGStickerPackShortnameReference alloc] initWithShortName:concreteStickerset.short_name];
                    }
                    
                    [attributes addObject:[[TGDocumentAttributeSticker alloc] initWithAlt:concreteAttribute.alt packReference:packReference]];
                }
                else if ([attribute isKindOfClass:[TLDocumentAttribute$documentAttributeVideo class]])
                {
                }
                else if ([attribute isKindOfClass:[TLDocumentAttribute$documentAttributeAudio class]])
                {
                    TLDocumentAttribute$documentAttributeAudio *concreteAttribute = attribute;
                    
                    [attributes addObject:[[TGDocumentAttributeAudio alloc] initWithTitle:concreteAttribute.title performer:concreteAttribute.performer duration:concreteAttribute.duration]];
                }
            }
            self.attributes = attributes;
            self.mimeType = concreteDocument.mime_type;
            self.size = concreteDocument.size;
            
            NSData *cachedData = nil;
            TGImageInfo *thumbmailInfo = concreteDocument.thumb == nil ? nil : [[TGImageInfo alloc] initWithTelegraphSizesDescription:@[concreteDocument.thumb] cachedData:&cachedData];
            if (thumbmailInfo != nil && !thumbmailInfo.empty)
            {
                self.thumbnailInfo = thumbmailInfo;
                if (cachedData != nil)
                {
                    static NSString *filesDirectory = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^
                    {
                        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                    });
                    
                    NSString *fileDirectoryName = nil;
                    fileDirectoryName = [[NSString alloc] initWithFormat:@"%" PRIx64 "", self.documentId];
                    NSString *fileDirectory = [filesDirectory stringByAppendingPathComponent:fileDirectoryName];
                    
                    [[NSFileManager defaultManager] createDirectoryAtPath:fileDirectory withIntermediateDirectories:true attributes:nil error:nil];
                    
                    NSString *filePath = [fileDirectory stringByAppendingPathComponent:@"thumbnail"];
                    
                    [cachedData writeToFile:filePath atomically:true];
                }
            }
        }
    }
    return self;
}

- (instancetype)initWithSecret23Desc:(Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)desc
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGDocumentMediaAttachmentType;
        
        self.documentId = [desc.pid longLongValue];
        
        self.accessHash = [desc.accessHash longLongValue];
        self.datacenterId = [desc.dcId intValue];
        self.date = [desc.date intValue];
        
        NSMutableArray *attributes = [[NSMutableArray alloc] init];
        for (id attribute in desc.attributes)
        {
            if ([attribute isKindOfClass:[Secret23_DocumentAttribute_documentAttributeFilename class]])
            {
                Secret23_DocumentAttribute_documentAttributeFilename *concreteAttribute = attribute;
                [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:concreteAttribute.fileName]];
            }
            else if ([attribute isKindOfClass:[Secret23_DocumentAttribute_documentAttributeAnimated class]])
            {
                [attributes addObject:[[TGDocumentAttributeAnimated alloc] init]];
            }
            else if ([attribute isKindOfClass:[Secret23_DocumentAttribute_documentAttributeAudio class]])
            {
            }
            else if ([attribute isKindOfClass:[Secret23_DocumentAttribute_documentAttributeImageSize class]])
            {
                Secret23_DocumentAttribute_documentAttributeImageSize *concreteAttribute = attribute;
                [attributes addObject:[[TGDocumentAttributeImageSize alloc] initWithSize:CGSizeMake(concreteAttribute.w.integerValue, concreteAttribute.h.integerValue)]];
            }
            else if ([attribute isKindOfClass:[Secret23_DocumentAttribute_documentAttributeSticker class]])
            {
                [attributes addObject:[[TGDocumentAttributeSticker alloc] initWithAlt:nil packReference:nil]];
            }
            else if ([attribute isKindOfClass:[Secret23_DocumentAttribute_documentAttributeVideo class]])
            {
            }
        }
    
        self.attributes = attributes;
        self.mimeType = desc.mimeType;
        self.size = [desc.size intValue];
        
        NSData *cachedData = nil;
        TGImageInfo *thumbmailInfo = desc.thumb == nil ? nil : [[TGImageInfo alloc] initWithSecret23SizesDescription:@[desc.thumb] cachedData:&cachedData];
        if (thumbmailInfo != nil && !thumbmailInfo.empty)
        {
            self.thumbnailInfo = thumbmailInfo;
            if (cachedData != nil)
            {
                static NSString *filesDirectory = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                });
                
                NSString *fileDirectoryName = nil;
                fileDirectoryName = [[NSString alloc] initWithFormat:@"%" PRIx64 "", self.documentId];
                NSString *fileDirectory = [filesDirectory stringByAppendingPathComponent:fileDirectoryName];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:fileDirectory withIntermediateDirectories:true attributes:nil error:nil];
                
                NSString *filePath = [fileDirectory stringByAppendingPathComponent:@"thumbnail"];
                
                [cachedData writeToFile:filePath atomically:true];
            }
        }
    }
    return self;
}

@end
