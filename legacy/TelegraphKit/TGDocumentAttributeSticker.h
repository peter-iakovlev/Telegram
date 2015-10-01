#import "PSCoding.h"

#import "TGStickerPackReference.h"

@interface TGDocumentAttributeSticker : NSObject <PSCoding, NSCoding>

@property (nonatomic, strong, readonly) NSString *alt;
@property (nonatomic, strong, readonly) id<TGStickerPackReference> packReference;

- (instancetype)initWithAlt:(NSString *)alt packReference:(id<TGStickerPackReference>)packReference;

@end
