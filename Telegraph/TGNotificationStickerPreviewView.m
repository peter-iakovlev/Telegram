#import "TGNotificationStickerPreviewView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGImageView.h>
#import <LegacyComponents/UIImage+TG.h>

@interface TGNotificationStickerImageView : TGImageView

@end


@interface TGNotificationStickerPreviewView ()
{
    UIView *_wrapperView;
    TGNotificationStickerImageView *_imageView;
    
    CGSize _displaySize;
    NSString *_imageUri;
    bool _loaded;
}
@end

@implementation TGNotificationStickerPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGDocumentMediaAttachment *)attachment peers:(NSDictionary *)peers
{
    self = [super initWithMessage:message conversation:conversation peers:peers];
    if (self != nil)
    {
        self.userInteractionEnabled = false;
        
        CGSize imageSize = CGSizeZero;
        NSString *stickerRepresentation = nil;
        for (id attribute in attachment.attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
            else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                imageSize = ((TGDocumentAttributeVideo *)attribute).size;
            }
            else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                stickerRepresentation = ((TGDocumentAttributeSticker *)attribute).alt;
        }
        
        NSString *text = TGLocalized(@"Message.Sticker");
        if (stickerRepresentation.length > 0)
            text = [[NSString alloc] initWithFormat:@"%@ %@", stickerRepresentation, TGLocalized(@"Message.Sticker")];
        
        [self setIcon:nil text:text];
        
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (iosMajorVersion() >= 7)
            _wrapperView.layer.allowsGroupOpacity = true;
        [self addSubview:_wrapperView];
        
        _imageView = [[TGNotificationStickerImageView alloc] init];
        _imageView.alpha = 0.0f;
        _imageView.expectExtendedEdges = true;
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [_wrapperView addSubview:_imageView];
        
        CGSize displaySize = [self displaySizeForSize:imageSize];
        
        NSMutableString *imageUri = [[NSMutableString alloc] init];
        [imageUri appendString:@"sticker://?"];
        if (attachment.documentId != 0)
            [imageUri appendFormat:@"&documentId=%" PRId64, attachment.documentId];
        else
            [imageUri appendFormat:@"&localDocumentId=%" PRId64, attachment.localDocumentId];
        [imageUri appendFormat:@"&accessHash=%" PRId64, attachment.accessHash];
        [imageUri appendFormat:@"&datacenterId=%d", (int)attachment.datacenterId];
        [imageUri appendFormat:@"&fileName=%@", [TGStringUtils stringByEscapingForURL:attachment.fileName]];
        [imageUri appendFormat:@"&size=%d", (int)attachment.size];
        [imageUri appendFormat:@"&width=%d&height=%d", (int)displaySize.width, (int)displaySize.height];
        [imageUri appendFormat:@"&mime-type=%@", [TGStringUtils stringByEscapingForURL:attachment.mimeType]];
        
        _displaySize = displaySize;
        _imageUri = imageUri;
    }
    return self;
}

- (void)setExpandProgress:(CGFloat)progress
{
    _expandProgress = progress;
    
    if (progress > FLT_EPSILON && !_loaded)
    {
        _loaded = true;
        [_imageView loadUri:_imageUri withOptions:@{}];
    }
    
    _wrapperView.alpha = progress * progress;
    [self _updateExpandProgress:progress hideText:true];
    
    [self setNeedsLayout];
}

- (CGFloat)expandedHeightForContainerSize:(CGSize)containerSize
{
    [super expandedHeightForContainerSize:containerSize];
    
    return _headerHeight + _displaySize.height + 37.0f;
}

- (CGSize)displaySizeForSize:(CGSize)size
{
    CGFloat maxHeight = 128.0f;
    
    int screenSize = (int)TGScreenSize().height;
    if (screenSize < 568)
        maxHeight = 96;

    return TGFitSize(CGSizeMake(size.width / 2.0f, size.height / 2.0f), CGSizeMake(maxHeight, maxHeight));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat progress = _expandProgress;
    _imageView.frame = CGRectMake(TGNotificationPreviewContentInset.left, _textLabel.frame.origin.y + 4, _displaySize.width * progress, _displaySize.height * progress);
}

@end


@implementation TGNotificationStickerImageView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.expectExtendedEdges)
    {
        UIEdgeInsets insets = [self.currentImage extendedEdgeInsets];
        _extendedInsetsImageView.frame = CGRectMake(-insets.left, -insets.top, self.bounds.size.width + insets.left + insets.right, self.bounds.size.height + insets.top + insets.bottom);
    }
}

@end
