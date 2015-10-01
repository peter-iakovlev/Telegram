#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputStickerSet;

@interface TLDocumentAttribute : NSObject <TLObject>


@end

@interface TLDocumentAttribute$documentAttributeImageSize : TLDocumentAttribute

@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;

@end

@interface TLDocumentAttribute$documentAttributeAnimated : TLDocumentAttribute


@end

@interface TLDocumentAttribute$documentAttributeVideo : TLDocumentAttribute

@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;

@end

@interface TLDocumentAttribute$documentAttributeFilename : TLDocumentAttribute

@property (nonatomic, retain) NSString *file_name;

@end

@interface TLDocumentAttribute$documentAttributeSticker : TLDocumentAttribute

@property (nonatomic, retain) NSString *alt;
@property (nonatomic, retain) TLInputStickerSet *stickerset;

@end

@interface TLDocumentAttribute$documentAttributeAudio : TLDocumentAttribute

@property (nonatomic) int32_t duration;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *performer;

@end

