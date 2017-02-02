#import "TLWebPage.h"

@class TLPhoto;
@class TLDocument;
@class TLPage;

@interface TLWebPage_manual : TLWebPage

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t n_id;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *display_url;
@property (nonatomic) int32_t n_hash;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *site_name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *n_description;
@property (nonatomic, strong) TLPhoto *photo;
@property (nonatomic, strong) NSString *embed_url;
@property (nonatomic, strong) NSString *embed_type;
@property (nonatomic) int32_t embed_width;
@property (nonatomic) int32_t embed_height;
@property (nonatomic) int32_t duration;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) TLDocument *document;
@property (nonatomic, strong) TLPage *cached_page;

@end
