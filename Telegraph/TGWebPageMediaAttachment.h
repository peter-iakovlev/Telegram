#import "TGMediaAttachment.h"

#import "TGImageInfo.h"
#import "TGImageMediaAttachment.h"

#define TGWebPageMediaAttachmentType ((int)0x584197af)

@interface TGWebPageMediaAttachment : TGMediaAttachment <TGMediaAttachmentParser, NSCoding>

@property (nonatomic) int64_t webPageId;
@property (nonatomic) int32_t pendingDate;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *displayUrl;
@property (nonatomic, strong) NSString *pageType;
@property (nonatomic, strong) NSString *siteName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *pageDescription;
@property (nonatomic, strong) TGImageMediaAttachment *photo;
@property (nonatomic, strong) NSString *embedUrl;
@property (nonatomic, strong) NSString *embedType;
@property (nonatomic) CGSize embedSize;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSString *author;

@end
