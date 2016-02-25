#import "TGStickerKeyboardTabCell.h"

#import "TGDocumentMediaAttachment.h"
#import "TGImageView.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

@interface TGStickerKeyboardTabCell ()
{
    TGImageView *_imageView;
    TGStickerKeyboardViewStyle _style;
}

@end

@implementation TGStickerKeyboardTabCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _style = TGStickerKeyboardViewDefaultStyle;
        
        self.clipsToBounds = true;
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = UIColorRGB(0xe6e6e6);
        
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView reset];
}

- (void)setRecent
{
    [_imageView reset];
    _imageView.contentMode = UIViewContentModeCenter;
    
    UIImage *recentTabImage = [UIImage imageNamed:@"StickerKeyboardRecentTab.png"];
    if (_style == TGStickerKeyboardViewDarkBlurredStyle)
        _imageView.image = TGTintedImage(recentTabImage, UIColorRGB(0xb4b5b5));
    else
        _imageView.image = recentTabImage;
}

- (void)setNone
{
    [_imageView reset];
    _imageView.image = nil;
}

- (void)setDocumentMedia:(TGDocumentMediaAttachment *)documentMedia
{
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSMutableString *uri = [[NSMutableString alloc] initWithString:@"sticker-preview://?"];
    if (documentMedia.documentId != 0)
        [uri appendFormat:@"documentId=%" PRId64 "", documentMedia.documentId];
    else
        [uri appendFormat:@"localDocumentId=%" PRId64 "", documentMedia.localDocumentId];
    [uri appendFormat:@"&accessHash=%" PRId64 "", documentMedia.accessHash];
    [uri appendFormat:@"&datacenterId=%" PRId32 "", (int32_t)documentMedia.datacenterId];
    
    NSString *legacyThumbnailUri = [documentMedia.thumbnailInfo imageUrlForLargestSize:NULL];
    if (legacyThumbnailUri != nil)
        [uri appendFormat:@"&legacyThumbnailUri=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailUri]];
    
    [uri appendFormat:@"&width=33&height=33"];
    [uri appendFormat:@"&highQuality=1"];
    
    [_imageView loadUri:uri withOptions:nil];
}

- (void)setStyle:(TGStickerKeyboardViewStyle)style
{
    switch (style)
    {
        case TGStickerKeyboardViewDarkBlurredStyle:
            self.selectedBackgroundView.backgroundColor = UIColorRGB(0x393939);
            break;
            
        default:
            self.selectedBackgroundView.backgroundColor = UIColorRGB(0xe6e6e6);
            break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageSide = 33.0f;
    _imageView.frame = CGRectMake(CGFloor((self.frame.size.width - imageSide) / 2.0f), 6.0f, imageSide, imageSide);
}

@end
