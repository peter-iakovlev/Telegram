#import "TGStickerPackCollectionItemView.h"

#import "TGImageView.h"
#import "TGFont.h"
#import "TGStringUtils.h"
#import "TGImageUtils.h"

#import "TGDocumentMediaAttachment.h"

@interface TGStickerPackCollectionItemView ()
{
    TGImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_reorderingControl;
}

@end

@implementation TGStickerPackCollectionItemView

- (UIImage *)reorderingControlImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(22.0f, 9.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0xc7c7cc).CGColor);
        CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 22.0f, 2.0f - TGRetinaPixel));
        CGContextFillRect(context, CGRectMake(0.0f, 4.0f - TGRetinaPixel, 22.0f, 2.0f - TGRetinaPixel));
        CGContextFillRect(context, CGRectMake(0.0f, 7.0f, 22.0f, 2.0f - TGRetinaPixel));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.editingContentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGBoldSystemFontOfSize(15.0f);
        [self.editingContentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = UIColorRGB(0x808080);
        _subtitleLabel.font = TGSystemFontOfSize(14.0f);
        [self.editingContentView addSubview:_subtitleLabel];
        
        _reorderingControl = [[UIImageView alloc] initWithImage:[self reorderingControlImage]];
        _reorderingControl.alpha = 0.0f;
        [self.contentView addSubview:_reorderingControl];
        
        self.separatorInset = 60.0f;
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView reset];
}

- (void)setStickerPack:(TGStickerPack *)stickerPack
{
    NSString *title = stickerPack.title;
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
        title = TGLocalized(@"StickerPack.BuiltinPackName");
    _titleLabel.text = title;
    
    _subtitleLabel.text = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"StickerPack.StickerCount_" value:stickerPack.documents.count]), [[NSString alloc] initWithFormat:@"%d", (int)stickerPack.documents.count]];
    
    if (stickerPack.documents.count != 0)
    {
        TGDocumentMediaAttachment *documentMedia = stickerPack.documents[0];
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
        
        [uri appendFormat:@"&width=68&height=68"];
        [uri appendFormat:@"&highQuality=1"];
        [_imageView loadUri:uri withOptions:@{}];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGFloat leftInset = self.showsDeleteIndicator ? 38.0f : 0.0f;
    CGFloat rightInset = self.showsDeleteIndicator ? 38.0f : 0.0f;
    self.separatorInset = 60.0f + leftInset;
    
    [super layoutSubviews];
    
    _imageView.frame = CGRectMake(13.0f + leftInset, CGFloor((self.frame.size.height - 34.0f) / 2.0f), 34.0f, 34.0f);
    
    CGFloat titleSubtitleSpacing = 2.0f;
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(self.frame.size.width - leftInset - 60.0f - 8.0f - rightInset, titleSize.width);
    CGSize subtitleSize = [_subtitleLabel.text sizeWithFont:_subtitleLabel.font];
    
    CGFloat verticalOrigin = CGFloor((self.frame.size.height - titleSize.height - subtitleSize.height - titleSubtitleSpacing) / 2.0f);
    
    _titleLabel.frame = CGRectMake(leftInset + 60.0f, verticalOrigin, titleSize.width, titleSize.height);
    _subtitleLabel.frame = CGRectMake(leftInset + 60.0f, verticalOrigin + 2.0f + titleSize.height + titleSubtitleSpacing, subtitleSize.width, subtitleSize.height);
    
    _reorderingControl.alpha = 0.0f;//self.showsDeleteIndicator ? 1.0f : 0.0f;
    _reorderingControl.frame = CGRectMake(self.contentView.frame.size.width - 15.0f - _reorderingControl.frame.size.width, CGFloor((self.contentView.frame.size.height - _reorderingControl.frame.size.height) / 2.0f), _reorderingControl.frame.size.width, _reorderingControl.frame.size.height);
}

- (void)deleteAction
{
    if (_deleteStickerPack)
        _deleteStickerPack();
}

@end
