#import "TGWebDocument+Telegraph.h"

#import "TLWebDocument.h"
#import "TGDocumentMediaAttachment+Telegraph.h"

@implementation TGWebDocument (Telegraph)

- (instancetype)initWithTL:(TLWebDocument *)webDocument
{
    if ([webDocument isKindOfClass:[TLWebDocument$webDocument class]])
    {
        TLWebDocument$webDocument *desc = (TLWebDocument$webDocument *)webDocument;
        self = [self initWithNoProxy:false url:desc.url accessHash:desc.access_hash size:desc.size mimeType:desc.mime_type attributes:[TGDocumentMediaAttachment parseAttribtues:desc.attributes] datacenterId:-1];
    }
    else
    {
        TLWebDocument$webDocumentNoProxy *desc = (TLWebDocument$webDocumentNoProxy *)webDocument;
        self = [self initWithNoProxy:true url:desc.url accessHash:0 size:desc.size mimeType:desc.mime_type attributes:[TGDocumentMediaAttachment parseAttribtues:desc.attributes] datacenterId:0];
    }
    return self;
}

@end
