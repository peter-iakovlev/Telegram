#import "TGStickersCollectionCell.h"
#import "TGImageView.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGDocumentMediaAttachment.h"
#import "TGStickerAssociation.h"

NSString *const TGStickersCollectionCellIdentifier = @"TGStickersCollectionCell";

@interface TGStickersCollectionCell ()
{
    UIView *_wrapperView;
    TGImageView *_imageView;
    UILabel *_altLabel;
    
    NSString *_uri;
    
    TGDocumentMediaAttachment *_sticker;
    NSArray *_associations;
    bool _highlighted;
    NSInteger _altTick;
}
@end

@implementation TGStickersCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.opaque = true;
        self.backgroundColor = [UIColor whiteColor];
        
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_wrapperView];
        
        _imageView = [[TGImageView alloc] init];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.opaque = true;
        [_wrapperView addSubview:_imageView];
        
        _altLabel = [[UILabel alloc] init];
        _altLabel.backgroundColor = [UIColor clearColor];
        _altLabel.textColor = [UIColor blackColor];
        _altLabel.font = [UIFont systemFontOfSize:20.0f];
        [_wrapperView addSubview:_altLabel];
        
        _wrapperView.layer.rasterizationScale = TGScreenScaling();
    }
    return self;
}

- (TGDocumentMediaAttachment *)sticker
{
    return _sticker;
}

- (void)setSticker:(TGDocumentMediaAttachment *)documentMedia associations:(NSArray *)associations mask:(bool)mask
{
    _sticker = documentMedia;
    
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
    
    [uri appendFormat:@"&width=132&height=132"];
    [uri appendFormat:@"&highQuality=1"];
    
    if (![uri isEqualToString:_uri])
    {
        _uri = uri;
        [_imageView loadUri:uri withOptions:@{}];
    }
    
    NSString *alt = @"";
    for (id attribute in documentMedia.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            alt = ((TGDocumentAttributeSticker *)attribute).alt;
            break;
        }
    }
    
    NSMutableArray *stickerAssociations = [[NSMutableArray alloc] init];
    for (TGStickerAssociation *association in associations)
    {
        for (NSNumber *nDocumentId in association.documentIds)
        {
            if ((int64_t)[nDocumentId longLongValue] == documentMedia.documentId)
            {
                //[stickerAssociations addObject:association.key];
                
                if (alt.length == 0)
                {
                    alt = association.key;
                    break;
                }
            }
        }
    }
    _associations = stickerAssociations;
    
    //NSInteger altIndex = MAX(0, _altTick) % _associations.count;
    NSString *currentAlt = alt; //_associations[altIndex];
    if ([currentAlt characterAtIndex:0] == 0x2639)
        currentAlt = @"\u2639\ufe0f";
    
    _altLabel.text = !mask ? currentAlt : @"";
    _altLabel.transform = CGAffineTransformIdentity;
    [_altLabel sizeToFit];
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

- (void)performTransitionIn
{
    _wrapperView.layer.shouldRasterize = false;
    
    CGRect targetAltFrame = _altLabel.frame;
    _altLabel.frame = CGRectOffset(_altLabel.frame, 0, 20);
    
    [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^
    {
        _altLabel.frame = targetAltFrame;
    } completion:^(__unused BOOL finished)
    {
        _wrapperView.layer.shouldRasterize = true;
    }];
}

- (void)setAltTick:(NSInteger)tick
{
    _altTick = tick;
    
    if (_associations.count == 0)
        return;
    
    NSInteger altIndex = _altTick % _associations.count;
    NSString *currentAlt = _associations[altIndex];
    if ([currentAlt isEqualToString:_altLabel.text])
        return;
    
    _altLabel.text = currentAlt;
    [_altLabel sizeToFit];
    _altLabel.frame = CGRectMake(self.bounds.size.width - _altLabel.frame.size.width, self.bounds.size.height - _altLabel.frame.size.height + 4.0f, _altLabel.frame.size.width, _altLabel.frame.size.height);
    
    _altLabel.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    [UIView animateWithDuration:0.36 delay:0.0 usingSpringWithDamping:0.72f initialSpringVelocity:0.0f options:0 animations:^
    {
        _altLabel.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)layoutSubviews
{
    _wrapperView.frame = self.bounds;
    _imageView.frame = self.bounds;
    _altLabel.frame = CGRectMake(self.bounds.size.width - _altLabel.frame.size.width, self.bounds.size.height - _altLabel.frame.size.height + 4.0f, _altLabel.frame.size.width, _altLabel.frame.size.height);
}

@end
