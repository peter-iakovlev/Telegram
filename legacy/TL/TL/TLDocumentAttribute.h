#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputStickerSet;
@class TLMaskCoords;

@interface TLDocumentAttribute : NSObject <TLObject>


@end

@interface TLDocumentAttribute$documentAttributeImageSize : TLDocumentAttribute

@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;

@end

@interface TLDocumentAttribute$documentAttributeAnimated : TLDocumentAttribute


@end

@interface TLDocumentAttribute$documentAttributeFilename : TLDocumentAttribute

@property (nonatomic, retain) NSString *file_name;

@end

@interface TLDocumentAttribute$documentAttributeStickerMeta : TLDocumentAttribute

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *alt;
@property (nonatomic, retain) TLInputStickerSet *stickerset;
@property (nonatomic, retain) TLMaskCoords *mask_coords;

@end

@interface TLDocumentAttribute$documentAttributeHasStickers : TLDocumentAttribute


@end

@interface TLDocumentAttribute$documentAttributeVideo : TLDocumentAttribute

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;

@end

