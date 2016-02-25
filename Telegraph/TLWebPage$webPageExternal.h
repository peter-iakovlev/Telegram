#import "TLWebPage.h"

@interface TLWebPage$webPageExternal : TLWebPage

@property (nonatomic) int32_t flags;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *display_url;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *n_description;
@property (nonatomic, strong) NSString *thumb_url;
@property (nonatomic, strong) NSString *contentUrl;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic) int32_t duration;

@end
