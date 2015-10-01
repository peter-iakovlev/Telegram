#import "TGSingleStickerPreviewView.h"

#import "TGDocumentMediaAttachment.h"

#import "TGMessageImageView.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

@interface TGSingleStickerPreviewView ()
{
    UIView *_dimView;
    UIView *_imageViewContainer;
    TGMessageImageView *_imageView;
}

@end

@implementation TGSingleStickerPreviewView

- (CGSize)displaySizeForSize:(CGSize)size
{
    CGSize maxSize = CGSizeMake(160, 170);
    return TGFitSize(CGSizeMake(size.width / 2.0f, size.height / 2.0f), maxSize);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _dimView = [[UIView alloc] init];
        _dimView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        _dimView.alpha = 0.0f;
        [self addSubview:_dimView];
        
        _imageViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
        _imageViewContainer.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        [self addSubview:_imageViewContainer];
        
        _imageView = [[TGMessageImageView alloc] init];
        _imageView.expectExtendedEdges = true;
        _imageView.alpha = 0.0f;
        [_imageViewContainer addSubview:_imageView];
    }
    return self;
}

- (void)setDocument:(TGDocumentMediaAttachment *)document
{
    if (document.documentId != _document.documentId || document.localDocumentId != _document.localDocumentId)
    {
        _document = document;
        
        bool isAnimated = false;
        CGSize imageSize = CGSizeZero;
        bool isSticker = false;
        bool isAudio = false;
        for (id attribute in document.attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
            {
                isAnimated = true;
            }
            else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
            {
                imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
            }
            else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
            {
                isSticker = true;
            }
            else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
            {
                isAudio = true;
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
        
        _imageView.frame = CGRectMake(CGFloor((100.0f - displaySize.width) / 2.0f), CGFloor((100.0f - displaySize.height) / 2.0f), displaySize.width, displaySize.height);
        
        [_imageView loadUri:imageUri withOptions:@{}];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _dimView.frame = bounds;
    
    _imageViewContainer.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
}

- (void)animateAppear
{
    _dimView.alpha = 0.0f;
    if (iosMajorVersion() < 8)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            _dimView.alpha = 1.0f;
            _imageView.alpha = 1.0f;
            _imageViewContainer.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.72f initialSpringVelocity:0.0f options:0 animations:^
        {
            _dimView.alpha = 1.0f;
            _imageView.alpha = 1.0f;
            _imageViewContainer.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (void)animateDismiss:(void (^)())completion
{
    [UIView animateWithDuration:0.2 animations:^
    {
        _dimView.alpha = 0.0f;
        _imageViewContainer.transform = CGAffineTransformMakeScale(0.3f, 0.3f);
        _imageViewContainer.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

@end
