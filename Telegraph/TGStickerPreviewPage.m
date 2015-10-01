#import "TGStickerPreviewPage.h"

#import "TGImageView.h"

#import "TGDocumentMediaAttachment.h"
#import "TGStringUtils.h"

#import "TGStickerAssociation.h"

@interface TGStickerPreviewPageImageView : TGImageView
{
}

@end

@implementation TGStickerPreviewPageImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
    }
    return self;
}

@end

@interface TGStickerPreviewPage ()
{
    NSArray *_imageViews;
    NSArray *_altLabels;
}

@end

@implementation TGStickerPreviewPage

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        NSMutableArray *imageViews = [[NSMutableArray alloc] init];
        NSMutableArray *altLabels = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++)
        {
            TGStickerPreviewPageImageView *imageView = [[TGStickerPreviewPageImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.hidden = true;
            [imageViews addObject:imageView];
            [self addSubview:imageView];
            
            UILabel *altLabel = [[UILabel alloc] init];
            altLabel.backgroundColor = [UIColor clearColor];
            altLabel.textColor = [UIColor blackColor];
            altLabel.font = [UIFont systemFontOfSize:20.0f];
            altLabel.hidden = true;
            [altLabels addObject:altLabel];
            [self addSubview:altLabel];
        }
        _imageViews = imageViews;
        _altLabels = altLabels;
    }
    return self;
}

- (void)prepareForReuse
{
    for (TGStickerPreviewPageImageView *imageView in _imageViews)
    {
        imageView.hidden = true;
        [imageView reset];
    }
    
    for (UILabel *altLabel in _altLabels)
    {
        altLabel.hidden = true;
    }
}

- (void)setDocuments:(NSArray *)documents stickerAssociations:(NSArray *)stickerAssociations
{
    for (NSUInteger i = 0; i < documents.count && i < _imageViews.count; i++)
    {
        TGStickerPreviewPageImageView *imageView = _imageViews[i];
        imageView.hidden = false;

        TGDocumentMediaAttachment *documentMedia = documents[i];
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
        [imageView loadUri:uri withOptions:@{}];
        
        NSString *alt = @"";
        for (id attribute in documentMedia.attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
            {
                alt = ((TGDocumentAttributeSticker *)attribute).alt;
                break;
            }
        }
        
        if (alt.length == 0)
        {
            for (TGStickerAssociation *association in stickerAssociations)
            {
                for (NSNumber *nDocumentId in association.documentIds)
                {
                    if ((int64_t)[nDocumentId longLongValue] == documentMedia.documentId)
                    {
                        alt = association.key;
                        break;
                    }
                }
            }
        }
        
        UILabel *altLabel = _altLabels[i];
        altLabel.hidden = false;
        altLabel.text = alt;
        [altLabel sizeToFit];
    }
    
    for (NSUInteger i = documents.count; i < _imageViews.count; i++)
    {
        TGStickerPreviewPageImageView *imageView = _imageViews[i];
        imageView.hidden = true;
        [imageView reset];
        
        UILabel *altLabel = _altLabels[i];
        altLabel.hidden = true;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize imageSize = CGSizeMake(66.0f, 66.0f);
    CGFloat horizontalSpacing = 20.0f;
    CGFloat verticalSpacing = 8.0f;
    
    NSInteger index = -1;
    for (TGStickerPreviewPageImageView *imageView in _imageViews)
    {
        index++;
        
        imageView.frame = CGRectMake((index % 3) * (imageSize.width + horizontalSpacing), (index / 3) * (imageSize.height + verticalSpacing), imageSize.width, imageSize.height);
        
        UILabel *altLabel = _altLabels[index];
        altLabel.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - altLabel.frame.size.width, imageView.frame.origin.y + imageView.frame.size.height - altLabel.frame.size.height, altLabel.frame.size.width, altLabel.frame.size.height);
    }
}

@end
