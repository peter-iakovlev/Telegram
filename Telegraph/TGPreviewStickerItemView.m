#import "TGPreviewStickerItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGDocumentMediaAttachment.h"
#import "TGStickerAssociation.h"

#import "TGMessageImageView.h"

@interface TGPreviewStickerItemView ()
{
    CGSize _imageSize;
    
    TGMessageImageView *_imageView;
}
@end

@implementation TGPreviewStickerItemView

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        CGSize imageSize = CGSizeZero;
        bool isSticker = false;
        for (id attribute in document.attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
            else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                isSticker = true;
        }
        
        CGSize displaySize = [self displaySizeForSize:imageSize];
        _imageSize = displaySize;
        
        NSMutableString *imageUri = [[NSMutableString alloc] init];
        [imageUri appendString:@"sticker://?"];
        if (document.documentId != 0)
            [imageUri appendFormat:@"&documentId=%" PRId64, document.documentId];
        else
            [imageUri appendFormat:@"&localDocumentId=%" PRId64, document.localDocumentId];
        [imageUri appendFormat:@"&accessHash=%" PRId64, document.accessHash];
        [imageUri appendFormat:@"&datacenterId=%d", (int)document.datacenterId];
        [imageUri appendFormat:@"&fileName=%@", [TGStringUtils stringByEscapingForURL:document.fileName]];
        [imageUri appendFormat:@"&size=%d", (int)document.size];
        [imageUri appendFormat:@"&width=%d&height=%d", (int)displaySize.width, (int)displaySize.height];
        [imageUri appendFormat:@"&mime-type=%@", [TGStringUtils stringByEscapingForURL:document.mimeType]];
        
        _imageView = [[TGMessageImageView alloc] init];
        _imageView.expectExtendedEdges = true;
        [self addSubview:_imageView];
        
        _imageView.frame = CGRectMake(0, 0, displaySize.width, displaySize.height);
        
        [_imageView loadUri:imageUri withOptions:@{}];
    }
    return self;
}

- (CGSize)displaySizeForSize:(CGSize)size
{
    CGSize maxSize = CGSizeMake(160, 170);
    return TGFitSize(CGSizeMake(size.width / 2.0f, size.height / 2.0f), maxSize);
}

- (bool)requiresClearBackground
{
    return true;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)__unused event
{
    return CGRectContainsPoint(_imageView.frame, point);
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    return _imageSize.height;
}

- (void)layoutSubviews
{
    _imageView.frame = CGRectMake(CGFloor((self.frame.size.width - _imageView.frame.size.width) / 2.0f), CGFloor((self.frame.size.height - _imageView.frame.size.height) / 2.0f), _imageView.frame.size.width, _imageView.frame.size.height);
}

@end
