#import "TGStickerWebpageFooterModel.h"

#import "TGMessageImageViewModel.h"

#import "TGWebPageMediaAttachment.h"
#import "TGDocumentMediaAttachment.h"
#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGMessageImageView.h"

@interface TGStickerWebpageFooterModel () {
    TGWebPageMediaAttachment *_webPage;
    bool _hasViews;
    bool _incoming;
    
    TGMessageImageViewModel *_imageModel;
}

@end

@implementation TGStickerWebpageFooterModel

- (CGSize)displaySizeForSize:(CGSize)size
{
    CGSize maxSize = CGSizeMake(160, 170);
    return TGFitSize(CGSizeMake(size.width / 2.0f, size.height / 2.0f), maxSize);
}

- (instancetype)initWithContext:(TGModernViewContext *)__unused context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage hasViews:(bool)hasViews {
    _webPage = webPage;
    _hasViews = hasViews;
    _incoming = incoming;
    
    TGDocumentMediaAttachment *_document = webPage.document;
    if (_document != nil) {
        _imageModel = [[TGMessageImageViewModel alloc] init];
        _imageModel.expectExtendedEdges = true;
        _imageModel.timestampHidden = true;
        _imageModel.overlayBackgroundColorHint = UIColorRGBA(0x000000, 0.4f);
        
        CGSize imageSize = [_document pictureSize];
        if (imageSize.width <= FLT_EPSILON || imageSize.height <= FLT_EPSILON)
        {
            CGSize size = CGSizeZero;
            [_document.thumbnailInfo imageUrlForLargestSize:&size];
            if (size.width > FLT_EPSILON && size.height > FLT_EPSILON) {
                imageSize = TGFillSize(TGFitSize(size, CGSizeMake(512.0f, 512.0f)), CGSizeMake(512.0f, 512.0f));
            } else {
                imageSize = CGSizeMake(512.0f, 512.0f);
            }
        }
        
        CGSize displaySize = [self displaySizeForSize:imageSize];
        
        NSMutableString *imageUri = [[NSMutableString alloc] init];
        [imageUri appendString:@"sticker://?"];
        if (_document.documentId != 0)
            [imageUri appendFormat:@"&documentId=%" PRId64, _document.documentId];
        else
            [imageUri appendFormat:@"&localDocumentId=%" PRId64, _document.localDocumentId];
        [imageUri appendFormat:@"&accessHash=%" PRId64, _document.accessHash];
        [imageUri appendFormat:@"&datacenterId=%d", (int)_document.datacenterId];
        [imageUri appendFormat:@"&fileName=%@", [TGStringUtils stringByEscapingForURL:_document.fileName]];
        [imageUri appendFormat:@"&size=%d", (int)_document.size];
        [imageUri appendFormat:@"&width=%d&height=%d", (int)displaySize.width, (int)displaySize.height];
        [imageUri appendFormat:@"&mime-type=%@", [TGStringUtils stringByEscapingForURL:_document.mimeType]];
        
        [_imageModel setUri:imageUri];
        
        _imageModel.frame = CGRectMake(0.0f, 0.0f, displaySize.width, displaySize.height);
        _imageModel.skipDrawInContext = true;
        [self addSubmodel:_imageModel];
    }
    return self;
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _imageModel.parentOffset = itemPosition;
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
    //(((TGMessageImageViewContainer *)[_imageModel boundView])).imageView.delegate = self;
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    //(((TGMessageImageViewContainer *)[_imageModel boundView])).imageView.delegate = self;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [super unbindView:viewStorage];
}

- (void)updateSpecialViewsPositions:(CGPoint)itemPosition
{
    _imageModel.parentOffset = itemPosition;
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize contentSize:(CGSize)__unused topContentSize infoWidth:(CGFloat)__unused infoWidth needsContentsUpdate:(bool *)__unused needsContentsUpdate
{
    CGSize size = _imageModel.frame.size;
    size.width += 4.0f;
    size.height += 4.0f;
    return size;
}

- (bool)preferWebpageSize
{
    return false;
}

- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)__unused bottomInset
{
    rect.origin.y -= 9.0f;
    
    _imageModel.frame = CGRectMake(rect.origin.x + 9.0f + (_incoming ? 5.0f : 0.0f), rect.origin.y + 9.0f, _imageModel.frame.size.width, _imageModel.frame.size.height);
}

@end
