#import <LegacyComponents/LegacyComponents.h>

@class TLPhoto;
@class TLDocument;
@class TLWallPaper;

@interface TGMediaOriginInfo (Telegraph)

+ (instancetype)mediaOriginInfoForPhoto:(TLPhoto *)desc;
+ (instancetype)mediaOriginInfoForPhoto:(TLPhoto *)desc cid:(int64_t)cid mid:(int32_t)mid;
+ (instancetype)mediaOriginInfoForPhoto:(TLPhoto *)desc webpageUrl:(NSString *)webpageUrl;

+ (instancetype)mediaOriginInfoForDocument:(TLDocument *)desc;
+ (instancetype)mediaOriginInfoForDocument:(TLDocument *)desc cid:(int64_t)cid mid:(int32_t)mid;
+ (instancetype)mediaOriginInfoForDocument:(TLDocument *)desc stickerPackId:(int64_t)stickerPackId stickerPackAccessHash:(int64_t)stickerPackAccessHash;
+ (instancetype)mediaOriginInfoForDocumentRecentSticker:(TLDocument *)desc;
+ (instancetype)mediaOriginInfoForDocumentFavoriteSticker:(TLDocument *)desc;
+ (instancetype)mediaOriginInfoForDocumentRecentGif:(TLDocument *)desc;
+ (instancetype)mediaOriginInfoForDocumentRecentMask:(TLDocument *)desc;
+ (instancetype)mediaOriginInfoForDocument:(TLDocument *)desc webpageUrl:(NSString *)webpageUrl;

+ (instancetype)mediaOriginInfoForWallpaper:(TLWallPaper *)desc;

@end
