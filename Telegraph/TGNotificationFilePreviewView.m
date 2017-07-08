#import "TGNotificationFilePreviewView.h"
#import "TGNotificationView.h"

#import "TGDocumentMediaAttachment.h"
#import "TGSharedMediaController.h"

#import "TGImageView.h"
#import "TGSharedMediaFileThumbnailView.h"

#import "TGStringUtils.h"
#import "TGFont.h"

@interface TGNotificationFilePreviewView ()
{
    UIView *_wrapperView;
    TGSharedMediaFileThumbnailView *_iconView;
    UILabel *_extensionLabel;
    TGImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_sizeLabel;
    
    NSString *_imageUri;
    bool _loaded;
    NSString *_legacyThumbnailCacheUri;
}
@end

@implementation TGNotificationFilePreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGDocumentMediaAttachment *)attachment peers:(NSDictionary *)peers
{
    self = [super initWithMessage:message conversation:conversation peers:peers];
    if (self != nil)
    {
        self.userInteractionEnabled = false;
        
        NSString *text = TGLocalized(@"Message.File");
        if (attachment.fileName.length > 0)
            text = attachment.fileName;
    
        [self setIcon:[UIImage imageNamed:@"MediaFile"] text:text];
        
        _wrapperView = [[UIView alloc] initWithFrame:CGRectMake(TGNotificationPreviewContentInset.left, 0, 0, 29)];
        _wrapperView.alpha = 0.0f;
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (iosMajorVersion() >= 7)
            _wrapperView.layer.allowsGroupOpacity = true;
        _wrapperView.userInteractionEnabled = false;
        [self addSubview:_wrapperView];
        
        CGSize dimensions = CGSizeZero;
        _legacyThumbnailCacheUri = [attachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
        dimensions.width *= 10.0f;
        dimensions.height *= 10.0f;
        
        if ((attachment.documentId != 0 || attachment.localDocumentId != 0) && _legacyThumbnailCacheUri.length != 0)
        {
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
            if (attachment.documentId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", attachment.documentId];
            else
                [previewUri appendFormat:@"local-id=%" PRId64 "", attachment.localDocumentId];
            
            [previewUri appendFormat:@"&file-name=%@", [attachment.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            CGSize thumbnailSize = CGSizeMake(30.0f, 30.0f);
            CGSize renderSize = CGSizeZero;
            if (dimensions.width < dimensions.height)
            {
                renderSize.height = CGFloor((dimensions.height * thumbnailSize.width / dimensions.width));
                renderSize.width = thumbnailSize.width;
            }
            else
            {
                renderSize.width = CGFloor((dimensions.width * thumbnailSize.height / dimensions.height));
                renderSize.height = thumbnailSize.height;
            }
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            [previewUri appendString:@"&rounded=1"];
            
            if (_legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:_legacyThumbnailCacheUri]];
            
            _imageUri = previewUri;
        }

        if (_imageUri == nil)
        {
            _iconView = [[TGSharedMediaFileThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
            [_iconView setStyle:TGSharedMediaFileThumbnailViewStyleRounded colors:[TGSharedMediaController thumbnailColorsForFileName:attachment.fileName]];
            [_wrapperView addSubview:_iconView];
            
            NSString *extString = [attachment.fileName.pathExtension lowercaseString];
            extString = extString.length > 5 ? [extString substringToIndex:5] : extString;
            
            _extensionLabel = [[UILabel alloc] init];
            _extensionLabel.backgroundColor = [UIColor clearColor];
            _extensionLabel.textColor = [UIColor whiteColor];
            _extensionLabel.font = TGMediumSystemFontOfSize(10.0f);
            _extensionLabel.text = extString;
            [_wrapperView addSubview:_extensionLabel];
            
            [_extensionLabel sizeToFit];
            _extensionLabel.frame = CGRectMake(CGFloor(_iconView.frame.origin.x + (_iconView.frame.size.width - _extensionLabel.frame.size.width) / 2.0f), 1.0f + CGFloor(_iconView.frame.origin.y + (_iconView.frame.size.height - _extensionLabel.frame.size.height) / 2.0f), ceil(_extensionLabel.frame.size.width), ceil(_extensionLabel.frame.size.height));
        }
        else
        {
            _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
            [_wrapperView addSubview:_imageView];
        }
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = TGMediumSystemFontOfSize(13);
        _nameLabel.text = attachment.fileName;
        _nameLabel.textColor = [UIColor whiteColor];
        [_wrapperView addSubview:_nameLabel];
        
        [_nameLabel sizeToFit];
        _nameLabel.frame = CGRectMake(36, -1, ceil(_nameLabel.frame.size.width), ceil(_nameLabel.frame.size.height));
        
        NSString *sizeString = @"";
        if (attachment.size >= 1024 * 1024)
            sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Megabytes"), (float)attachment.size / (1024 * 1024)];
        else if (attachment.size >= 1024)
            sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Kilobytes"), (int)(attachment.size / 1024)];
        else
            sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Bytes"), (int)(attachment.size)];
        
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.backgroundColor = [UIColor clearColor];
        _sizeLabel.font = TGSystemFontOfSize(13);
        _sizeLabel.text = sizeString;
        _sizeLabel.textColor = [UIColor whiteColor];
        [_wrapperView addSubview:_sizeLabel];
        
        [_sizeLabel sizeToFit];
        _sizeLabel.frame = CGRectMake(36, 15, ceil(_sizeLabel.frame.size.width), ceil(_sizeLabel.frame.size.height));
    }
    return self;
}

- (void)setExpandProgress:(CGFloat)progress
{
    _expandProgress = progress;
    
    if (_imageView != nil && progress > FLT_EPSILON && !_loaded)
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
    return _headerHeight + TGNotificationDefaultHeight + 2;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _wrapperView.frame = CGRectMake(_wrapperView.frame.origin.x, _textLabel.frame.origin.y + 4, self.frame.size.width - _wrapperView.frame.origin.x - TGNotificationPreviewContentInset.right, _wrapperView.frame.size.height);
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, _wrapperView.frame.size.width - _nameLabel.frame.origin.x, _nameLabel.frame.size.height);
    _sizeLabel.frame = CGRectMake(_sizeLabel.frame.origin.x, _sizeLabel.frame.origin.y, _wrapperView.frame.size.width - _sizeLabel.frame.origin.x, _sizeLabel.frame.size.height);
}

@end
