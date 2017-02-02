#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLStickerSet;
@class TLDocument;

@interface TLStickerSetCovered : NSObject <TLObject>

@property (nonatomic, retain) TLStickerSet *set;

@end

@interface TLStickerSetCovered$stickerSetCovered : TLStickerSetCovered

@property (nonatomic, retain) TLDocument *cover;

@end

@interface TLStickerSetCovered$stickerSetMultiCovered : TLStickerSetCovered

@property (nonatomic, retain) NSArray *covers;

@end

