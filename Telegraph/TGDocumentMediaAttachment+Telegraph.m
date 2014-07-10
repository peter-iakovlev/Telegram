/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDocumentMediaAttachment+Telegraph.h"

#import "TGImageInfo+Telegraph.h"

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
            self.userId = concreteDocument.user_id;
            self.date = concreteDocument.date;
            self.fileName = concreteDocument.file_name;
            self.mimeType = concreteDocument.mime_type;
            self.size = concreteDocument.size;
            
            TGImageInfo *thumbmailInfo = concreteDocument.thumb == nil ? nil : [[TGImageInfo alloc] initWithTelegraphSizesDescription:@[concreteDocument.thumb]];
            if (thumbmailInfo != nil && !thumbmailInfo.empty)
                self.thumbnailInfo = thumbmailInfo;
        }
    }
    return self;
}

@end
