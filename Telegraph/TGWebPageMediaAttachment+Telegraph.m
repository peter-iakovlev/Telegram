#import "TGWebPageMediaAttachment+Telegraph.h"

#import "TLWebPage_manual.h"

#import "TGImageMediaAttachment+Telegraph.h"

/*
 @property (nonatomic) int64_t webPageId;
 @property (nonatomic, strong) NSString *url;
 @property (nonatomic, strong) NSString *displayUrl;
 @property (nonatomic, strong) NSString *pageType;
 @property (nonatomic, strong) NSString *siteName;
 @property (nonatomic, strong) NSString *title;
 @property (nonatomic, strong) NSString *pageDescription;
 @property (nonatomic, strong) TGImageInfo *photoInfo;
 @property (nonatomic, strong) NSString *embedUrl;
 @property (nonatomic, strong) NSString *embedType;
 @property (nonatomic) CGSize embedSize;
 @property (nonatomic, strong) NSNumber *duration;
 @property (nonatomic, strong) NSString *author;
 */

@implementation TGWebPageMediaAttachment (Telegraph)

- (instancetype)initWithTelegraphWebPageDesc:(TLWebPage *)desc
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGWebPageMediaAttachmentType;
        
        if ([desc isKindOfClass:[TLWebPage_manual class]])
        {
            TLWebPage_manual *webPage = (TLWebPage_manual *)desc;
            
            self.webPageId = webPage.n_id;
            self.pendingDate = -1;
            self.url = webPage.url;
            self.displayUrl = webPage.display_url;
            self.pageType = webPage.type;
            self.siteName = webPage.site_name;
            self.title = webPage.title;
            self.pageDescription = webPage.n_description;
            if (webPage.photo != nil)
                self.photo = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:webPage.photo];
            self.embedUrl = webPage.embed_url;
            self.embedType = webPage.embed_type;
            self.embedSize = CGSizeMake(webPage.embed_width, webPage.embed_height);
            self.duration = (webPage.flags & (1 << 7)) ? @(webPage.duration) : 0;
            self.author = webPage.author;
        }
        else if ([desc isKindOfClass:[TLWebPage$webPagePending class]])
        {
            TLWebPage$webPagePending *webPage = (TLWebPage$webPagePending *)desc;
            self.webPageId = webPage.n_id;
            self.pendingDate = webPage.date;
        }
        else if ([desc isKindOfClass:[TLWebPage$webPageEmpty class]])
        {
            TLWebPage$webPageEmpty *webPage = (TLWebPage$webPageEmpty *)desc;
            self.webPageId = webPage.n_id;
            self.pendingDate = -1;
        }
    }
    return self;
}

@end
