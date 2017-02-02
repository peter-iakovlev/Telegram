#import "TGStickerAssociatedInputPanelCell.h"

#import "TGDocumentMediaAttachment.h"
#import "TGImageView.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

@interface TGStickerAssociatedInputPanelCell ()
{
    TGImageView *_imageView;
    
    bool _highlighted;
}

@end

@implementation TGStickerAssociatedInputPanelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(3.0f - TGRetinaPixel, 3.0f, 64.0f, 64.0f)];
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

- (void)setDocument:(TGDocumentMediaAttachment *)document
{
    _document = document;
    
    NSMutableString *uri = [[NSMutableString alloc] initWithString:@"sticker-preview://?"];
    if (document.documentId != 0)
        [uri appendFormat:@"documentId=%" PRId64 "", document.documentId];
    else
        [uri appendFormat:@"localDocumentId=%" PRId64 "", document.localDocumentId];
    [uri appendFormat:@"&accessHash=%" PRId64 "", document.accessHash];
    [uri appendFormat:@"&datacenterId=%" PRId32 "", (int32_t)document.datacenterId];
    
    NSString *legacyThumbnailUri = [document.thumbnailInfo imageUrlForLargestSize:NULL];
    if (legacyThumbnailUri != nil)
        [uri appendFormat:@"&legacyThumbnailUri=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailUri]];
    
    [uri appendFormat:@"&width=128&height=128"];
    [uri appendFormat:@"&highQuality=1"];
    
    [_imageView loadUri:uri withOptions:nil];
}

- (void)setHighlighted:(bool)highlighted animated:(bool)__unused animated
{
    if (_highlighted != highlighted)
    {
        _highlighted = highlighted;
        
        if (iosMajorVersion() >= 8)
        {
            [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                if (_highlighted)
                    _imageView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
                else
                    _imageView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

@end
