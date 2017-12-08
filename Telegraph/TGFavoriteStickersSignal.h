#import <SSignalKit/SSignalKit.h>

@class TGDocumentMediaAttachment;

@interface TGFavoriteStickersSignal : NSObject

+ (void)clearFavoriteStickers;
+ (void)sync;
+ (bool)isFaved:(TGDocumentMediaAttachment *)sticker;
+ (void)setSticker:(TGDocumentMediaAttachment *)document faved:(bool)faved;
+ (SSignal *)favoriteStickers;

@end
