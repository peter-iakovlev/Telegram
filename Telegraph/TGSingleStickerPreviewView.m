#import "TGSingleStickerPreviewView.h"

#import "TGDocumentMediaAttachment.h"
#import "TGStickerAssociation.h"

#import "TGMessageImageView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

static const CGFloat TGStickersTopMargin = 100.0f;

@interface TGSingleStickerPreviewView ()
{
    UIView *_dimView;
    UIView *_imageViewContainer;
    TGMessageImageView *_imageView;
    
    UIView *_altWrapperView;
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
        _imageViewContainer.alpha = 0.0f;
        [self addSubview:_imageViewContainer];
        
        _altWrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 40.0f)];
        [_imageViewContainer addSubview:_altWrapperView];
        
        _imageView = [[TGMessageImageView alloc] init];
        _imageView.expectExtendedEdges = true;
        [_imageViewContainer addSubview:_imageView];
    }
    return self;
}

- (void)setDocument:(TGDocumentMediaAttachment *)document
{
    [self setDocument:document associations:nil];
}

- (void)setDocument:(TGDocumentMediaAttachment *)document associations:(NSArray *)associations
{
    if (document.documentId != _document.documentId || document.localDocumentId != _document.localDocumentId)
    {
        bool animated = false;
        if (iosMajorVersion() >= 7 && _document != document)
            animated = true;
        
        _document = document;
        
        bool isAnimated = false;
        CGSize imageSize = CGSizeZero;
        bool isSticker = false;
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
            else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                imageSize = ((TGDocumentAttributeVideo *)attribute).size;
            }
            else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
            {
                isSticker = true;
            }
        }
    
        NSMutableArray *alts = [[NSMutableArray alloc] init];
        for (TGStickerAssociation *association in associations)
        {
            for (NSNumber *nDocumentId in association.documentIds)
            {
                if ((int64_t)[nDocumentId longLongValue] == document.documentId)
                    [alts addObject:association.key];
            }
        }
        
        [self updateAltViews:alts animated:animated];
        if (_altWrapperView.superview == _imageViewContainer)
        {
            _altWrapperView.frame = CGRectMake(CGFloor(_imageViewContainer.frame.size.width - _altWrapperView.frame.size.width) / 2.0f, -TGStickersTopMargin, _altWrapperView.frame.size.width, _altWrapperView.frame.size.height);
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
        
        if (animated)
        {
            _imageViewContainer.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
            [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.72f initialSpringVelocity:0.0f options:0 animations:^
            {
                _imageViewContainer.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

- (void)updateAltViews:(NSArray *)alts animated:(bool)animated
{
    for (UIView *view in _altWrapperView.subviews)
        [view removeFromSuperview];
    
    NSInteger i = 0;
    UIView *lastAltView = nil;
    for (NSString *alt in alts)
    {
        UILabel *altView = [[UILabel alloc] initWithFrame:CGRectZero];
        altView.font = TGSystemFontOfSize(32);
        altView.text = alt;
        [altView sizeToFit];
        [_altWrapperView addSubview:altView];
        
        altView.frame = CGRectMake(i * 42.0f, 0, altView.frame.size.width, altView.frame.size.height);
        i++;
        
        if (animated)
        {
            altView.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
            [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.72f initialSpringVelocity:0.0f options:0 animations:^
            {
                altView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
        
        lastAltView = altView;
    }
    
    CGRect frame = _altWrapperView.frame;
    frame.size.width = CGRectGetMaxX(lastAltView.frame);
    _altWrapperView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect previousBounds = _dimView.bounds;
    CGPoint imageContainerCenter = [self _imageViewContainerCenter];
    if (!CGRectEqualToRect(self.bounds, previousBounds))
    {
        _dimView.frame = self.bounds;
        _imageViewContainer.center = imageContainerCenter;
    }
    
    if (_altWrapperView.superview == self)
    {
        _altWrapperView.frame = CGRectMake(imageContainerCenter.x - _altWrapperView.frame.size.width / 2.0f, imageContainerCenter.y - _imageViewContainer.frame.size.height / 2.0f - TGStickersTopMargin, _altWrapperView.frame.size.width, _altWrapperView.frame.size.height);
    }
}

- (CGPoint)_imageViewContainerCenter
{
    CGRect bounds = self.bounds;
    
    CGFloat y = bounds.size.height / 2.0f;
    if (bounds.size.height > bounds.size.width && self.eccentric)
        y = bounds.size.height / 3.0f;
    
    return CGPointMake(bounds.size.width / 2.0f, y);
}

- (void)animateAppear
{
    CGPoint transitionInPoint = CGPointZero;
    if (self.sourcePointForDocument != nil)
        transitionInPoint = self.sourcePointForDocument(self.document);
    
    bool animatedCenter = false;
    if (!CGPointEqualToPoint(transitionInPoint, CGPointZero))
    {
        _imageViewContainer.center = transitionInPoint;
        animatedCenter = true;
    }
    
    _dimView.alpha = 0.0f;
    _imageViewContainer.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    void (^changeBlock)(void) = ^
    {
        _dimView.alpha = 1.0f;
        _imageViewContainer.alpha = 1.0f;
        _imageViewContainer.transform = CGAffineTransformIdentity;
        
        if (animatedCenter)
            _imageViewContainer.center = [self _imageViewContainerCenter];
    };
    
    void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
    {
        if (finished)
        {
            _altWrapperView.frame = [_imageViewContainer convertRect:_altWrapperView.frame fromView:self];
            [self addSubview:_altWrapperView];
        }
    };
    
    if (iosMajorVersion() >= 7)
    {
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.72f initialSpringVelocity:0.0f options:0 animations:changeBlock completion:completionBlock];
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:changeBlock completion:completionBlock];        
    }
}

- (void)animateDismiss:(void (^)())completion
{
    CGPoint transitionOutPoint = CGPointZero;
    if (self.sourcePointForDocument != nil)
        transitionOutPoint = self.sourcePointForDocument(self.document);
    
    if (_altWrapperView.superview != _imageViewContainer)
    {
        _altWrapperView.frame = [self convertRect:_altWrapperView.frame toView:_imageViewContainer];
        [_imageViewContainer addSubview:_altWrapperView];
    }
    
    [UIView animateWithDuration:0.2 animations:^
    {
        _dimView.alpha = 0.0f;
        _imageViewContainer.transform = CGAffineTransformMakeScale(0.3f, 0.3f);
        _imageViewContainer.alpha = 0.0f;
        
        if (!CGPointEqualToPoint(transitionOutPoint, CGPointZero))
            _imageViewContainer.center = transitionOutPoint;
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

@end
